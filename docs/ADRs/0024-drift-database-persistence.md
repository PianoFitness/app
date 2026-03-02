# ADR-0024: Drift for Database Persistence

**Status:** Accepted

**Date:** 2026-03-02

## Context

Piano Fitness requires persistent local storage to record practice history, user preferences, and exercise progress. As the app targets multiple platforms (iOS, Android, macOS, Linux, Windows, and web), the persistence layer must work reliably across all of them.

Key requirements for the persistence layer:

- **Cross-platform**: Must work on all supported platforms (see [ADR-0022](0022-platform-support-strategy.md))
- **Type safety**: Queries and schema should be validated at compile time to prevent runtime errors
- **Reactivity**: UI should update automatically when underlying data changes, consistent with the MVVM pattern (see [ADR-0002](0002-mvvm-presentation-pattern.md))
- **Testability**: Must integrate cleanly with the repository pattern and mock infrastructure (see [ADR-0004](0004-repository-pattern-external-dependencies.md), [ADR-0009](0009-repository-level-test-mocking.md))
- **SQLite foundation**: Relational data model suits structured practice records and user data

## Decision

We adopt **Drift** (`drift` + `drift_flutter`) as the database persistence library for all local storage needs in Piano Fitness.

Drift (formerly Moor) is a reactive, type-safe persistence library for Flutter and Dart built on top of SQLite. It generates strongly-typed Dart code from table definitions and queries, catching schema and query mistakes at compile time rather than at runtime.

The database layer is implemented in the **application layer** (`lib/application/`) behind repository interfaces defined in the **domain layer** (`lib/domain/repositories/`), preserving Clean Architecture boundaries (see [ADR-0001](0001-clean-architecture-three-layers.md)).

**Primary packages added:**

| Package                | Role                                              |
| ---------------------- | ------------------------------------------------- |
| `drift`                | Core ORM and query API                            |
| `drift_flutter`        | Flutter-specific SQLite bindings (cross-platform) |
| `path_provider`        | Resolve platform database file paths              |
| `drift_dev` *(dev)*    | Code generation tooling                           |
| `build_runner` *(dev)* | Drives code generation                            |

## Consequences

### Positive

- **Type-safe queries**: Generated code means SQL mistakes are caught at compile time, reducing runtime crashes
- **Reactivity**: Drift streams integrate naturally with ChangeNotifier/Provider and ViewModel patterns already in use, enabling auto-updating UI without manual refresh calls
- **Cross-platform**: `drift_flutter` provides a unified SQLite backend across iOS, Android, macOS, Linux, Windows, and web — no platform-conditional storage code required
- **Rich query API**: Supports complex joins, window functions, WITH clauses, transactions, and batched updates without sacrificing readability
- **Schema migrations**: Built-in migration support keeps schema evolution manageable and auditable
- **Testability**: Drift supports in-memory databases for fast, deterministic unit tests behind repository interfaces
- **Battle-tested**: Drift is production-stable, widely used, and actively maintained

### Negative

- **Code generation step**: Table definitions and queries require running `build_runner` to regenerate `.g.dart` files; this adds a build step to the development workflow
- **Learning curve**: Developers unfamiliar with Drift must learn both its Dart query API and generate/rebuild cycle
- **Generated file churn**: `.g.dart` files change whenever the schema changes, increasing diff noise in pull requests

### Neutral

- Drift stores data in an SQLite file on disk; no migration from an existing storage format is required since this is the initial persistence implementation
- Drift's threading/isolate support is available but not required for the current feature set

## Related Decisions

- [ADR-0001: Clean Architecture with Three Layers](0001-clean-architecture-three-layers.md)
- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md)
- [ADR-0004: Repository Pattern for External Dependencies](0004-repository-pattern-external-dependencies.md)
- [ADR-0009: Repository-Level Test Mocking](0009-repository-level-test-mocking.md)
- [ADR-0022: Platform Support Strategy](0022-platform-support-strategy.md)

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Database table definitions and generated code: `lib/application/database/`
- Repository interfaces: `lib/domain/repositories/`
- Repository implementations (Drift-backed): `lib/application/repositories/`
- Dependency injection wiring: `lib/main.dart`
- Test helpers with in-memory Drift databases: `test/shared/test_helpers/`
