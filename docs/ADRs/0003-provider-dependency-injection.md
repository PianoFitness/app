# ADR-0003: Provider for Dependency Injection

**Status:** Accepted

**Date:** 2024-01-01

## Context

The application needed a dependency injection solution that would:
- Enable constructor injection for ViewModels
- Manage singleton and scoped instances
- Support testing with mock dependencies
- Integrate well with Flutter's widget tree
- Provide reactive state management

Alternative solutions considered:
- **GetIt**: Service locator pattern, but less idiomatic for Flutter
- **Riverpod**: More powerful but higher learning curve
- **Injectable**: Code generation overhead
- **Manual DI**: Complex for 7 ViewModels with multiple dependencies

## Decision

Use Provider package for dependency injection with MultiProvider at app root.

**Implementation:**

1. **Application Root** (`lib/main.dart`):
   - MultiProvider wraps MyApp
   - Registers 5 dependencies:
     - `Provider<IMidiRepository>` (singleton)
     - `Provider<INotificationRepository>` (singleton)
     - `Provider<ISettingsRepository>` (singleton)
     - `Provider<IAudioService>` (singleton factory)
     - `ChangeNotifierProvider<MidiState>` (global shared state)

2. **Feature Pages**:
   - Wrap ViewModel in ChangeNotifierProvider
   - Inject dependencies via ViewModel constructor
   - Example:
     ```dart
     ChangeNotifierProvider(
       create: (context) => PlayPageViewModel(
         midiRepository: context.read<IMidiRepository>(),
         midiState: context.read<MidiState>(),
       ),
       child: PlayPageView(),
     )
     ```

3. **Testing**:
   - Override providers with mocks using ProviderScope
   - Clean, isolated tests without plugin dependencies

## Consequences

### Positive

- **Constructor Injection** - ViewModels receive dependencies explicitly
- **Type Safety** - Compile-time checking for dependency types
- **Testing** - Easy mock injection via Provider overrides
- **Flutter Integration** - Idiomatic for Flutter widget tree
- **Reactive Updates** - ChangeNotifier pattern built-in
- **Minimal Boilerplate** - No code generation required

### Negative

- **Widget Tree Coupling** - Dependencies tied to widget hierarchy
- **Runtime Errors** - Missing providers cause runtime exceptions (not compile-time)
- **Rebuild Scope** - Must carefully manage Consumer/select for performance

### Neutral

- **Provider Package** - Single external dependency for DI
- **MultiProvider Pattern** - Standard approach in Flutter ecosystem

## Related Decisions

- [ADR-0002: MVVM Pattern](0002-mvvm-presentation-pattern.md) - ViewModel architecture
- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - What gets injected
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - ChangeNotifierProvider for shared state
- [ADR-0010: Shared Test Helper](0010-shared-test-helper-infrastructure.md) - Testing with Provider overrides

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- MultiProvider configuration: `lib/main.dart`
- ViewModel injection examples: `lib/features/*/`
- Test helper with Provider overrides: `test/shared/test_helpers/widget_test_helper.dart`
- Phase 2 DI refactoring: `REFACTOR_DI.md`
