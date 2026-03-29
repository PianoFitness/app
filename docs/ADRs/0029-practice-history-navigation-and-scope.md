# ADR-0029: Practice History Page — Navigation Placement and MVP Scope

**Status:** Accepted

**Date:** 2026-03-29

## Context

Phase 1 of the exercise history feature (ADR-0025, ADR-0028) established a reliable data layer: a Drift-backed table, a DAO, and a repository interface. Every exercise completion is now recorded. The next milestone is to surface that data to users.

Two structural choices had to be made before building the UI:

**1. Where should the History page live in the navigation?**

The app currently has four bottom navigation tabs: Free Play, Practice, Reference, Repertoire. Candidate placements were:

- **Nested inside the Practice hub** — History is closely related to practice, so nesting it there is semantically reasonable. However, reaching it would take two taps from the bottom bar, and it would be invisible unless the user is already exploring the Practice section. The history log's value as a motivational tool depends on visibility.
- **Accessible from the Profile button in the AppBar** — Profile is the natural owner of personal data. However, it lives in a modal/supplementary navigation context (pushed via `Navigator`), which makes History feel like an administrative detail rather than a practitioner-facing feature. The `AppBar` profile button is already used as the gateway to profile management; mixing in content browsing would blur that responsibility.
- **A new fifth bottom navigation tab** — A dedicated tab makes History a first-class, always-visible feature. It reinforces the habit loop: see the tab, remember to practise, come back and see the record. The `BottomNavigationBar` uses `BottomNavigationBarType.fixed`, which supports five tabs without overflow on the targeted screen sizes (macOS, iOS, web).

**2. How much should the MVP History page do?**

The Phase 2 deliverables in the original `exercise-history.md` spec described date-grouped lists, aggregate statistics (streaks, most-practised keys), and mode/date filters. Building all of that at once would delay shipping the feature and add complexity before verifying that the basic timeline is useful. Statistics and filters depend on additional query methods, aggregation logic, and UI components not yet in place.

The simplest useful page is a flat, reverse-chronological list with one general-purpose card widget per entry. All entries share the same `ExerciseHistoryEntry` data model, so a single card covers all six practice modes without specialisation. Grouping, stats, and filters can be added incrementally on top of this foundation once the page is live.

## Decision

1. The Practice History page is registered as a **fifth permanent tab** in `MainNavigation`, alongside Free Play, Practice, Reference, and Repertoire.

2. The MVP page displays a **flat reverse-chronological timeline** of `ExerciseHistoryEntry` rows using a single general-purpose `HistoryEntryCard` widget. It includes loading, empty, and error states but no date grouping, statistics, or filters.

## Consequences

### Positive

- History is always one tap away from anywhere in the app, maximising its motivational visibility.
- A single `HistoryEntryCard` serving all six practice modes keeps the widget tree shallow and the code easy to test.
- The flat timeline can be shipped immediately; grouping, stats, and filters can be layered on later without restructuring the page scaffold or ViewModel.
- The `HistoryPageViewModel` exposes a clean, minimal state surface (`isLoading`, `error`, `entries`) that is straightforward to test and extend.

### Negative

- Five tabs is one more than the current four; on very narrow screens the labels may be truncated. In practice the app targets macOS, iOS (larger devices), and web, where five fixed tabs remain legible.
- Deferring date grouping means entries flow as a flat list, which may be harder to scan once large amounts of data have accumulated. This is an acceptable tradeoff for the MVP.

### Neutral

- Adding a tab to `MainNavigation` is a small, low-risk change: add an entry to `_pages`, `_pageTitles`, `_pageIcons`, and the `BottomNavigationBar` items list.
- The `HistoryPage` + `HistoryPageViewModel` pattern is identical to existing feature pages (Repertoire, Practice, Play), so it introduces no new patterns into the codebase.

## Related Decisions

- [ADR-0025: Exercise History Data Model](0025-exercise-history-data-model.md)
- [ADR-0026: Unified Exercise Configuration Model](0026-unified-exercise-configuration-model.md)
- [ADR-0028: Exercise History Configuration-Mirroring Schema](0028-exercise-history-configuration-mirroring-schema.md)
- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md)
- [ADR-0003: Provider for Dependency Injection](0003-provider-dependency-injection.md)
- [ADR-0004: Repository Pattern for External Dependencies](0004-repository-pattern-external-dependencies.md)
- [ADR-0027: Migrate Feature Modules into Presentation Layer](0027-migrate-features-to-presentation-layer.md)

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Feature specification: `docs/specifications/practice-history-page.md`
- Data layer specification: `docs/specifications/exercise-history.md`
- History feature implementation: `lib/presentation/features/history/`
- Navigation: `lib/presentation/widgets/main_navigation.dart`
