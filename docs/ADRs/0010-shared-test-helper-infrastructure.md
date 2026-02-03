# ADR-0010: Shared Test Helper Infrastructure

**Status:** Accepted

**Date:** 2026-02-03

## Context

During Phase 2 test migration, every widget test required identical Provider setup:

```dart
// Duplicated across 20+ test files (100+ lines total)
testWidgets('test description', (tester) async {
  final mockMidiRepo = MockIMidiRepository();
  final mockNotificationRepo = MockINotificationRepository();
  final mockSettingsRepo = MockISettingsRepository();
  final mockAudioService = MockIAudioService();
  final midiState = MidiState();
  
  when(mockAudioService.createPlayer()).thenReturn(MockAudioPlayer());
  
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<IMidiRepository>(create: (_) => mockMidiRepo),
        Provider<INotificationRepository>(create: (_) => mockNotificationRepo),
        Provider<ISettingsRepository>(create: (_) => mockSettingsRepo),
        Provider<IAudioService>(create: (_) => mockAudioService),
        ChangeNotifierProvider<MidiState>(create: (_) => midiState),
      ],
      child: MaterialApp(home: WidgetUnderTest()),
    ),
  );
});
```

**Problems:**
- **Massive Duplication** - 100+ lines of identical setup code
- **Maintenance Burden** - Changes require updating 20+ test files
- **Easy to Forget** - Missing AudioService stubbing causes MissingStubError
- **Verbose Tests** - Setup obscures actual test logic

**DRY Principle Violation:** Don't Repeat Yourself - shared setup should be centralized.

## Decision

Create `widget_test_helper.dart` with two functions:

1. **`createTestWidget()`** - Standard helper for 95% of tests
   - Automatic mock creation with sensible defaults
   - Automatic AudioService stubbing
   - MaterialApp wrapping
   
2. **`createTestWidgetWithMocks()`** - Custom helper for tests needing mock assertions
   - Caller provides specific mocks
   - Used in integration tests requiring spy/verify

**Implementation:**

```dart
// Standard usage (95% of tests)
await tester.pumpWidget(createTestWidget(PlayPage()));

// Custom mocks for assertions (5% of tests)
final mockMidiRepo = MockIMidiRepository();
await tester.pumpWidget(
  createTestWidgetWithMocks(
    PlayPage(),
    midiRepository: mockMidiRepo,
  ),
);
verify(mockMidiRepo.connect()).called(1);
```

**Benefits:**

- **100+ Lines Eliminated** - DRY principle applied
- **Automatic Stubbing** - AudioService.createPlayer() auto-stubbed
- **Consistent Setup** - All tests use same configuration
- **Easier Maintenance** - Single place to update test infrastructure
- **Clearer Tests** - Test logic not obscured by setup

## Consequences

### Positive

- **DRY Compliance** - Eliminated massive code duplication
- **Maintainability** - Single source of test configuration
- **Developer Experience** - Tests easier to write and understand
- **Automatic Safety** - Common stubbing mistakes prevented
- **Fast Adoption** - 68 tests migrated in single batch

### Negative

- **Hidden Magic** - Some test setup not visible in test file
- **Learning Curve** - Developers must know helper functions exist

### Neutral

- **Two Variants** - Standard and custom cover all test scenarios
- **Test File Location** - `test/shared/test_helpers/widget_test_helper.dart`

## Related Decisions

- [ADR-0003: Provider DI](0003-provider-dependency-injection.md) - What needs setup
- [ADR-0009: Repository Mocking](0009-repository-level-test-mocking.md) - What gets mocked
- [ADR-0011: Coverage Requirements](0011-test-coverage-requirements.md) - Test quality standards

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Shared helper: `test/shared/test_helpers/widget_test_helper.dart`
- Phase 2 migration: `REFACTOR_DI.md` "Shared Test Helper Infrastructure"
- Impact: 73 tests fixed, 42 tests fixed by helper alone
