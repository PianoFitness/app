# ADR-0001: Clean Architecture with Three Layers

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness needed an architectural foundation that would support long-term maintainability, testability, and platform independence. The application handles complex domain logic (music theory, MIDI processing), external infrastructure (MIDI devices, notifications, audio), and multiple UI features (play, practice, reference, etc.).

Without clear architectural boundaries, codebases tend toward:
- Business logic mixed with UI code
- Direct framework dependencies in domain code
- Difficult testing due to tight coupling
- Challenging refactoring and feature additions

## Decision

Adopt Clean Architecture with three distinct layers following the dependency rule: dependencies point inward from presentation → application → domain.

**Layer Structure:**

1. **Domain Layer** (`lib/domain/`)
   - Pure business logic and domain models
   - Zero dependencies on Flutter or external packages
   - Contains:
     - Models (entities, value objects)
     - Repository interfaces (abstractions)
     - Domain services (music theory algorithms)
     - Domain constants

2. **Application Layer** (`lib/application/`)
   - Service orchestration and infrastructure integration
   - Depends on domain layer only
   - Contains:
     - Repository implementations (infrastructure adapters)
     - Application services (MIDI connection, notifications)
     - Application state management
     - Application utilities

3. **Presentation Layer** (`lib/features/`, `lib/presentation/`)
   - UI components and presentation logic
   - Depends on domain and application layers
   - Contains:
     - Feature modules with MVVM pattern
     - Shared widgets and utilities
     - Theme and styling
     - Accessibility infrastructure

## Consequences

### Positive

- **Framework Independence** - Domain logic has zero Flutter dependencies, enabling reuse and testing
- **Testability** - Each layer can be tested in isolation with clear boundaries
- **Maintainability** - Changes in one layer have minimal impact on others
- **Scalability** - New features follow established patterns
- **Platform Flexibility** - Domain and application layers support all platforms without modification

### Negative

- **Learning Curve** - Team must understand layer boundaries and dependency rules
- **Initial Overhead** - More files and structure than simpler architectures
- **Indirection** - Repository pattern adds abstraction layer between ViewModels and services

### Neutral

- **Directory Structure** - Three top-level directories mirror the architecture
- **Import Rules** - Layer-specific import ordering enforced (see [ADR-0023: Import Organization](0023-import-organization-conventions.md))

## Related Decisions

- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md) - Presentation layer architecture
- [ADR-0004: Repository Pattern for External Dependencies](0004-repository-pattern-external-dependencies.md) - Application layer pattern
- [ADR-0013: Music Theory Domain Services](0013-music-theory-domain-services.md) - Domain layer implementation
- [ADR-0023: Import Organization Conventions](0023-import-organization-conventions.md) - Layer-specific import ordering

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Domain layer: `lib/domain/`
- Application layer: `lib/application/`
- Presentation layer: `lib/features/` and `lib/presentation/`
- Architecture documentation: `AGENTS.md` "Architecture Overview" section
