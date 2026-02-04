# ADR-0008: Notification Service Initialization in Repository Constructor

**Status:** Accepted

**Date:** 2026-02-03

## Context

`NotificationService` requires initialization before use (plugin setup, permission handling). Before Phase 2 refactoring:

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); // Static initialization
  runApp(MyApp());
}
```

**Problems with Static Initialization:**
- Initialization logic separated from service usage
- Repository pattern breaks when service needs pre-initialization
- Error handling far from where service is used
- Main function grows with initialization boilerplate

**Design Question:**
Who should own the initialization responsibility?

## Decision

Encapsulate `NotificationService.initialize()` within `NotificationRepositoryImpl` constructor with graceful error handling.

**Implementation:**

```dart
class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl() {
    _initialize();
  }
  
  void _initialize() {
    try {
      NotificationService.initialize();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Failed to initialize NotificationService: $e');
        print(stackTrace);
      }
      // Non-fatal - app continues without notifications
    }
  }
}
```

**Rationale:**

- **Encapsulation** - Repository owns service lifecycle
- **Proper Boundary** - Initialization at infrastructure layer, not main()
- **Graceful Degradation** - App continues if notifications unavailable
- **Testability** - Repository tests can verify initialization behavior

## Consequences

### Positive

- **Clean main()** - No static initialization calls
- **Repository Ownership** - Repository manages entire service lifecycle
- **Error Handling** - Initialization errors handled at proper boundary
- **Graceful Degradation** - App functional even if notifications fail
- **Testability** - Initialization behavior can be tested

### Negative

- **Constructor Side Effects** - Constructor performs I/O (acceptable for repository)
- **Hidden Initialization** - Initialization not visible at app startup (but logged)

### Neutral

- **Provider Pattern** - Repository created by Provider at app startup
- **One-Time Cost** - Initialization happens once when repository instantiated

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - Repository abstraction
- [ADR-0017: Notification Scheduling](0017-notification-scheduling-strategy.md) - What notifications do

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Implementation: `lib/application/repositories/notification_repository_impl.dart`
- Service being wrapped: `lib/application/services/notifications/notification_service.dart`
- Original decision: `REFACTOR_DI.md` "ADR-005"
