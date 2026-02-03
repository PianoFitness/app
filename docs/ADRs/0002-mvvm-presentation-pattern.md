# ADR-0002: MVVM Pattern in Presentation Layer

**Status:** Accepted

**Date:** 2024-01-01

## Context

The presentation layer needed a pattern that would:
- Separate UI rendering from business logic
- Enable thorough testing of feature-specific logic
- Support reactive UI updates
- Provide consistent structure across all features

Flutter provides multiple patterns (MVC, MVP, BLoC, MVVM). The application has 7 distinct features (Play, Practice, MIDI Settings, Device Controller, Notifications, Reference, Repertoire), each with unique business logic and state management needs.

## Decision

Adopt Model-View-ViewModel (MVVM) pattern with ChangeNotifier for all presentation features.

**Pattern Structure:**

- **View (Page)**: Pure UI layer handling user interactions
  - Stateless or StatefulWidget focused solely on UI
  - Delegates business logic to ViewModel
  - Uses Consumer/AnimatedBuilder for reactive updates
  - No business logic - only UI state management

- **ViewModel**: Feature-specific business logic
  - Extends ChangeNotifier for reactive state
  - Coordinates between View and domain/application layers
  - Processes data, manages feature state
  - Disposed properly in dispose() method

- **Model**: Domain entities and value objects
  - Defined in domain layer
  - Immutable data structures
  - Business rules and validation

**Feature Organization:**

```
lib/features/
├── play/
│   ├── play_page.dart              # View
│   └── play_page_view_model.dart   # ViewModel
├── practice/
│   ├── practice_page.dart
│   └── practice_page_view_model.dart
└── [5 more features...]
```

## Consequences

### Positive

- **Testability** - ViewModels are pure Dart classes, easy to unit test
- **Separation of Concerns** - Clear boundary between UI and business logic
- **Reactive UI** - ChangeNotifier pattern provides efficient UI updates
- **Consistency** - All 7 features follow same pattern
- **Maintainability** - Logic changes isolated to ViewModels, UI changes to Pages

### Negative

- **Boilerplate** - Each feature requires two files (Page + ViewModel)
- **ChangeNotifier Limitations** - Not as powerful as advanced state management solutions for complex state graphs

### Neutral

- **Provider Integration** - Requires Provider package for dependency injection (see [ADR-0003](0003-provider-dependency-injection.md))
- **Feature-Based Organization** - Each feature is self-contained module

## Related Decisions

- [ADR-0001: Clean Architecture Three Layers](0001-clean-architecture-three-layers.md) - Overall architecture
- [ADR-0003: Provider for Dependency Injection](0003-provider-dependency-injection.md) - ViewModel instantiation
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - Shared state across ViewModels
- [ADR-0012: Test Organization Mirrors Source](0012-test-organization-mirrors-source.md) - Testing structure

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Feature modules: `lib/features/`
- 7 MVVM implementations: play, practice, midi_settings, device_controller, notifications, reference, repertoire
- ViewModel examples: `lib/features/play/play_page_view_model.dart`
- MVVM documentation: `AGENTS.md` "MVVM Pattern Compliance" section
