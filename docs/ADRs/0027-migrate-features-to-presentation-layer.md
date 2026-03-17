# ADR-0027: Migrate Feature Modules into Presentation Layer

**Status:** Accepted

**Date:** 2026-03-16

## Context

The original Clean Architecture implementation (ADR-0001) defined the presentation layer as spanning two separate top-level directories:

- `lib/features/` — feature-based MVVM modules (Pages, ViewModels, feature-specific widgets and constants)
- `lib/presentation/` — shared presentation utilities (accessibility, constants, theme, utils, widgets)

This split created ambiguity: both directories belonged to the same architectural layer (presentation), but lived at the same level as the clearly distinct `lib/application/` and `lib/domain/` directories. New contributors and AI assistants often needed to consult documentation to understand that `features/` was part of the presentation layer, not a separate layer.

The intended architecture always had a single presentation layer — the dual-directory arrangement was a pragmatic starting point as the codebase grew. With the application reaching maturity, the overhead of maintaining this mental model outweighs its original convenience.

## Decision

Consolidate all feature modules from `lib/features/` into `lib/presentation/features/`, making `lib/presentation/` the sole top-level directory for all presentation-layer code.

**New directory structure:**

```text
lib/
├── presentation/
│   ├── features/           ← feature-based MVVM modules (was lib/features/)
│   │   ├── device_controller/
│   │   ├── midi_settings/
│   │   ├── notifications/
│   │   ├── play/
│   │   ├── practice/
│   │   ├── reference/
│   │   ├── repertoire/
│   │   └── user_profile/
│   ├── accessibility/      ← shared accessibility infrastructure
│   ├── constants/          ← shared UI constants
│   ├── theme/              ← theming and semantic colors
│   ├── utils/              ← shared presentation utilities
│   └── widgets/            ← shared reusable widgets
├── application/
└── domain/
```

Test files mirror the source structure: `test/presentation/features/` (was `test/features/`).

All `package:piano_fitness/features/` import paths are updated to `package:piano_fitness/presentation/features/`.

## Consequences

### Positive

- **Architectural clarity**: The directory structure now directly reflects the three-layer architecture — one top-level directory per layer
- **Reduced cognitive load**: No need to remember that `features/` and `presentation/` are the same layer
- **Consistent mental model**: New contributors immediately see three layers: `presentation/`, `application/`, `domain/`
- **Feature discoverability**: Feature modules remain grouped under `presentation/features/`, preserving the feature-first organization within the layer

### Negative

- **Import path changes**: All imports referencing `package:piano_fitness/features/` must be updated — a one-time mechanical change
- **Git history**: `git log --follow` is required to trace file history across the rename

### Neutral

- **No behavioral changes**: This is a pure structural refactoring — no logic, interfaces, or implementations are modified
- **MVVM pattern unchanged**: Each feature module retains its Page/ViewModel/widgets structure

## Related Decisions

- [ADR-0001: Clean Architecture with Three Layers](0001-clean-architecture-three-layers.md) — supersedes the dual-directory presentation layer definition
- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md) — pattern unchanged, now entirely within `lib/presentation/`
- [ADR-0012: Test Organization Mirrors Source Structure](0012-test-organization-mirrors-source.md) — test files moved to `test/presentation/features/`

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Feature modules: `lib/presentation/features/`
- Shared presentation: `lib/presentation/` (accessibility, constants, theme, utils, widgets)
- Test files: `test/presentation/features/`
