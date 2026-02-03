# ADR-0012: Test Organization Mirrors Source Structure

**Status:** Accepted

**Date:** 2024-01-01

## Context

Test organization affects discoverability, maintainability, and developer workflow. Different approaches:

**Option 1: Test-Type Organization**
```
test/
├── unit/
│   ├── all_model_tests.dart
│   └── all_service_tests.dart
├── widget/
└── integration/
```
- **Pros**: Tests grouped by type
- **Cons**: Hard to find tests for specific source file

**Option 2: Feature-Based Organization**
```
test/
├── play_feature/
├── practice_feature/
└── reference_feature/
```
- **Pros**: Feature isolation
- **Cons**: Doesn't match source structure, navigation difficult

**Option 3: Mirror Source Structure**
```
test/
├── domain/
│   └── services/
│       └── music_theory/
│           └── scales_test.dart
├── application/
│   └── state/
│       └── midi_state_test.dart
└── features/
    └── play/
        └── play_page_test.dart
```
- **Pros**: Easy navigation, clear correspondence
- **Cons**: More directories

## Decision

Test directory structure exactly mirrors `lib/` directory structure. Each source file has corresponding test file.

**Naming Convention:**
- Source: `lib/features/play/play_page.dart`
- Test: `test/features/play/play_page_test.dart`

**Benefits:**

1. **Discoverability** - Easy to find tests for any source file
2. **Navigation** - IDE navigation works seamlessly
3. **Maintainability** - File moves/renames reflected in tests
4. **Consistency** - Same structure everywhere

**Commands:**

```bash
# Test specific layers
flutter test test/domain/
flutter test test/application/
flutter test test/features/play/

# Test specific file
flutter test test/features/play/play_page_test.dart
```

## Consequences

### Positive

- **Easy Navigation** - Know exactly where to find tests
- **IDE Support** - Jump between source and test files
- **Clear Correspondence** - 1:1 mapping reduces confusion
- **Consistency** - Same pattern across entire codebase
- **Onboarding** - New developers understand structure immediately

### Negative

- **Directory Proliferation** - More directories than type-based organization
- **Deep Nesting** - Some test paths are long

### Neutral

- **Feature-Based MVVM** - Aligns perfectly with MVVM feature modules
- **Clean Architecture** - Test layers match source layers

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Source layer structure
- [ADR-0002: MVVM Pattern](0002-mvvm-presentation-pattern.md) - Feature module structure
- [ADR-0011: Coverage Requirements](0011-test-coverage-requirements.md) - Test quality standards

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Test structure: `test/` directory mirrors `lib/`
- Examples:
  - `lib/features/play/play_page_view_model.dart` → `test/features/play/play_page_view_model_test.dart`
  - `lib/domain/services/music_theory/scales.dart` → `test/domain/services/music_theory/scales_test.dart`
- Testing guidelines: `test/GUIDELINES.md`
