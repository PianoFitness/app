# ADR-0009: Repository-Level Test Mocking

**Status:** Accepted

**Date:** 2026-02-03

## Context

Before Phase 2 refactoring, tests used plugin-level mocking with `MidiMocks`:

```dart
setUp(() async {
  await MidiMocks.setUp(); // Mock flutter_midi_command MethodChannel
});

tearDown(() async {
  await MidiMocks.tearDown();
});
```

**Problems with Plugin-Level Mocking:**
- Complex setup requiring MethodChannel mocking
- Tightly coupled to flutter_midi_command implementation details
- Fragile tests breaking with plugin updates
- Duplicated mock setup across test files (100+ lines)
- Slower tests due to plugin layer complexity

**Clean Architecture Principle:**
Tests should mock at the boundary they control. ViewModels depend on repositories, not plugins.

## Decision

Replace plugin-level mocking with repository-level mocks using Provider overrides.

**New Approach:**

```dart
// Mockito-generated mocks
class MockIMidiRepository extends Mock implements IMidiRepository {}
class MockINotificationRepository extends Mock implements INotificationRepository {}

// Test setup with Provider overrides
testWidgets('PlayPage test', (tester) async {
  final mockMidiRepo = MockIMidiRepository();
  
  await tester.pumpWidget(
    createTestWidget( // Shared helper
      PlayPage(),
      mocks: ProviderOverrides(
        midiRepository: mockMidiRepo,
      ),
    ),
  );
});
```

**Rationale:**

- **Proper Abstraction** - Mock at repository boundary, not plugin
- **Clean Architecture** - Tests respect architectural layers
- **Simpler Setup** - Provider overrides cleaner than MethodChannel mocks
- **Decoupling** - Tests independent of plugin implementation
- **Faster Tests** - No plugin layer complexity

## Consequences

### Positive

- **Simpler Tests** - One-line Provider override vs. complex plugin mocking
- **Faster Execution** - No MethodChannel overhead
- **Better Isolation** - Tests focus on ViewModel logic
- **Less Brittle** - Independent of plugin implementation changes
- **DRY Principle** - Shared test helper eliminates duplication

### Negative

- **Mockito Dependency** - Requires mock code generation
- **Build Step** - Must run `build_runner` to generate mocks

### Neutral

- **Supersedes MidiMocks** - Removed all MidiMocks.setUp()/tearDown() calls
- **Shared Test Helper** - See [ADR-0010](0010-shared-test-helper-infrastructure.md)

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - What gets mocked
- [ADR-0003: Provider DI](0003-provider-dependency-injection.md) - How mocks are injected
- [ADR-0010: Shared Test Helper](0010-shared-test-helper-infrastructure.md) - Test helper implementation

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Mock generation: `test/shared/test_helpers/mock_repositories.mocks.dart`
- Shared test helper: `test/shared/test_helpers/widget_test_helper.dart`
- Phase 2 test migration: `REFACTOR_DI.md` "Test Migration Achievements"
- 73 tests fixed, 99.9% pass rate achieved
- Original decision: `REFACTOR_DI.md` "ADR-004"
