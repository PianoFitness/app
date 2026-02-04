# ADR-0004: Repository Pattern for External Dependencies

**Status:** Accepted

**Date:** 2026-02-03

## Context

The application integrated multiple external dependencies:
- **flutter_midi_command** - MIDI device communication
- **flutter_local_notifications** - Practice reminders
- **shared_preferences** - Settings persistence
- **audioplayers** - Repertoire audio playback

Direct use of these packages throughout the codebase created several issues:
- ViewModels tightly coupled to plugin APIs
- Testing required complex plugin-level mocking
- Changing implementations would affect many files
- Plugin-specific error handling duplicated everywhere

The Dependency Inversion Principle states: "Depend on abstractions, not concretions."

## Decision

Abstract all external dependencies behind repository interfaces defined in the domain layer, with implementations in the application layer.

**Repository Interfaces Created:**

1. **IMidiRepository** - MIDI device operations
   - Device connection/disconnection
   - MIDI message sending/receiving
   - Data handler registration

2. **INotificationRepository** - Local notifications
   - Permission management
   - Daily notification scheduling
   - Instant notification display

3. **ISettingsRepository** - Settings persistence
   - Load/save notification settings
   - Scheduled notification metadata

4. **IAudioService** - Audio playback (factory pattern)
   - Creates AudioPlayer instances for feature use

**Benefits:**

- ViewModels depend on abstractions (interfaces)
- Implementations wrap plugin complexity
- Clean testing with mock repositories
- Future platform-specific implementations possible

## Consequences

### Positive

- **Testability** - Mock repositories at boundary we control
- **Decoupling** - ViewModels independent of plugin APIs
- **Error Handling** - Centralized in repository implementations
- **Flexibility** - Easy to swap implementations
- **Clean Architecture** - Proper dependency inversion

### Negative

- **Indirection** - Extra abstraction layer adds complexity
- **Boilerplate** - Interface + implementation for each dependency
- **Learning Curve** - Team must understand repository pattern

### Neutral

- **Directory Structure** - Interfaces in `lib/domain/repositories/`, implementations in `lib/application/repositories/`
- **Provider Registration** - Repositories registered in main.dart MultiProvider

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Layer boundaries
- [ADR-0003: Provider DI](0003-provider-dependency-injection.md) - How repositories are injected
- [ADR-0005: MidiConnectionService Singleton](0005-midi-connection-service-singleton.md) - Internal singleton handling
- [ADR-0007: Audio Factory Pattern](0007-factory-pattern-audio-service.md) - Audio-specific repository design
- [ADR-0008: Notification Initialization](0008-notification-service-initialization.md) - Notification-specific repository design
- [ADR-0009: Repository-Level Mocking](0009-repository-level-test-mocking.md) - Testing strategy

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Repository interfaces: `lib/domain/repositories/`
- Repository implementations: `lib/application/repositories/`
- Provider registration: `lib/main.dart`
- Phase 2 DI refactoring: `REFACTOR_DI.md`
