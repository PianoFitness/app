# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Package Management

**IMPORTANT**: Always use Flutter CLI commands for package management, never edit pubspec.yaml manually:

```bash
# Add dependencies
flutter pub add package_name
flutter pub add --dev package_name  # dev dependencies
flutter pub add package_name:^1.0.0  # specific version

# Remove dependencies
flutter pub remove package_name

# Update dependencies
flutter pub get        # after manual changes
flutter pub upgrade    # upgrade to latest compatible
flutter pub outdated   # check for updates
```

### Development Workflow

```bash
# Run app
flutter run
flutter run -d device_id  # specific device
flutter run --release     # release mode

# Code quality (REQUIRED before commits)
flutter analyze     # static analysis
dart format .       # format code
dart fix --apply    # auto-fix issues

# Testing (MANDATORY for all changes)
flutter test                           # all tests
flutter test test/domain/              # domain layer tests
flutter test test/application/         # application layer tests
flutter test test/presentation/features/play/       # play feature tests
flutter test test/presentation/features/practice/   # practice feature tests
flutter test test/domain/services/music_theory/scales_test.dart                              # specific service test
flutter test test/presentation/features/play/play_page_test.dart                             # specific page test
flutter test test/presentation/features/practice/practice_page_view_model_test.dart          # specific ViewModel test
flutter test test/widget_integration_test.dart # integration tests
flutter test --coverage               # with coverage

# Coverage Analysis (REQUIRED)
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # View coverage report
# Note: genhtml (lcov) must be installed locally (e.g., `brew install lcov` or your OS equivalent).

# Pre-commit checklist
# 1. Tests pass: flutter test
# 2. Coverage ≥80%: flutter test --coverage
# 3. No analyzer issues: flutter analyze
# 4. Code formatted: dart format .

# Building
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
flutter build macos  # macOS

# Database Migrations (Drift)
dart run drift_dev make-migrations  # Generate schema files and migration code
# Run BEFORE adding/modifying tables to capture current schema
# Run AFTER bumping schemaVersion to generate migration helpers
flutter test test/application/database/app_database_migration_test.dart  # Test migrations
```

---

## Architecture

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full architecture reference: layer contracts, MVVM pattern, key patterns (repository interfaces, value objects, bridge/adapter), and enforcement mechanisms.

Key rules at a glance:

- Dependencies flow inward only: Presentation → Application → Domain
- Domain layer has no Flutter or infrastructure imports (pure Dart only)
- Interfaces defined in domain (`IMidiRepository`), implemented in application
- ViewModels are `ChangeNotifier`s; pages are thin `StatelessWidget`s that create providers
- All MIDI dispatch goes through `MidiDataHandler.dispatch()` in the application layer
- Run `./scripts/check-layer-boundaries.sh` to verify layer boundaries

---

## Development Workflow Checklist

### Before Committing Changes

**Code Quality**

- [ ] No constructors with >8 parameters (SRP violation indicator - use configuration objects)
- [ ] No build methods with >100 lines (God Widget indicator)
- [ ] No classes with >300 lines (God Class indicator)
- [ ] Widgets only handle UI rendering (no networking, navigation, or business logic)
- [ ] Services are injected into widgets rather than created inside build methods
- [ ] Complex conditional logic is extracted into separate components or abstractions
- [ ] New features added via interfaces/abstractions, not if-else modifications
- [ ] Complex widgets are broken into smaller, focused components
- [ ] Reusable widgets are properly organized in `presentation/shared/widgets/` or `features/<feature>/widgets/`

**Resource Management**

- [ ] All resources are properly disposed in dispose() methods
- [ ] Streams are canceled, controllers are disposed
- [ ] ViewModels call notifyListeners() after state changes
- [ ] No memory leaks from uncanceled listeners

**Testing Requirements**

- [ ] Tests pass: `flutter test`
- [ ] Coverage ≥80% for new/modified code: `flutter test --coverage`
- [ ] Tests cover new functionality with unit, widget, and integration tests
- [ ] Mock external dependencies appropriately

**Build and Quality Requirements**

- [ ] Code formatted: `dart format .` (or auto-formatted by lefthook)
- [ ] No analyzer issues: `flutter analyze`
- [ ] All auto-fixable issues resolved: `dart fix --apply`
- [ ] Build succeeds on target platforms (macOS, iOS, web - no Android tooling)

### Development Workflow Steps

1. **Feature Development**: Create feature directory with page/viewmodel pair following MVVM
2. **Widget Composition**: Break large widgets into smaller, focused components
3. **Domain Logic**: Implement business logic in domain services, not in ViewModels/pages
4. **Testing**: Write comprehensive unit, widget, and integration tests (≥80% coverage)
5. **Code Quality**: Automatic formatting, linting via git hooks (lefthook)
6. **Architecture Review**: Check for SRP violations and code smells before committing
7. **MIDI Integration**: Use centralized MIDI services and state management
8. **Musical Theory**: Leverage existing domain services for consistency

---

## Build Targets and Platform Support

### Primary Development Platforms

- **macOS**: Primary development platform (no Android tooling installed)
- **iOS**: Full support with Xcode integration
- **Web**: Browser-based deployment support
- **Linux/Windows**: Desktop platform support

### Build Commands

```bash
# macOS
flutter build macos --debug
flutter build macos --release

# iOS
flutter build ios --debug
flutter build ios --release

# Web
flutter build web

# Run on specific platform
flutter run -d macos
flutter run -d chrome
```

### Platform Requirements

- Flutter >= 3.22.0
- Dart >= 3.8.1
- Note: Cannot compile APK (no Android tooling installed)
- Piano layout changes should maintain 49-key constraint for consistency
- Exercise sequences should be validated to fit within 4-octave ranges
