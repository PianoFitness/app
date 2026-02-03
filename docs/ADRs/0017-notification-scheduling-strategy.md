# ADR-0017: Notification Scheduling Strategy

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness needs practice reminders with:

- **Local-First** - Works offline without cloud dependencies
- **User Controlled** - Enable/disable, customize time
- **Cross-Platform** - iOS, Android, macOS, Windows
- **Persistence** - Survives app restarts
- **Timezone Aware** - Respects user's local time

## Decision

Implement **local notification scheduling** using `flutter_local_notifications` package.

**Architecture:**

```
lib/
├── application/
│   └── services/
│       └── notifications/
│           ├── notification_service.dart     # Scheduling logic
│           └── notification_manager.dart     # Settings persistence
└── domain/
    └── models/
        └── notification_settings.dart        # Domain model
```

**NotificationService Responsibilities:**

1. **Schedule Notifications** - Daily reminders at user-specified time
2. **Cancel Notifications** - When user disables reminders
3. **Reschedule** - When user changes time
4. **Permission Handling** - Request platform permissions
5. **Timezone Handling** - Convert to local time

**NotificationManager Responsibilities:**

1. **Settings Persistence** - Save/load via ISettingsRepository
2. **Default Values** - 9:00 AM daily reminders
3. **State Management** - Notify listeners on changes

**Implementation Example:**
```dart
// Schedule daily reminder
await notificationService.scheduleNotification(
  id: 0,
  title: "Time to practice piano!",
  body: "Practice for 15 minutes today",
  scheduledTime: TimeOfDay(hour: 9, minute: 0),
  repeatInterval: RepeatInterval.daily,
);
```

**Settings Persistence:**
```dart
class NotificationSettings {
  final bool enabled;
  final TimeOfDay scheduledTime;
  
  // Stored in shared_preferences via ISettingsRepository
}
```

**Initialization (ADR-0008):**
- Initialized in NotificationRepository constructor
- Graceful degradation on permission failure
- Silent failure logs error but continues

## Consequences

### Positive

- **Offline Support** - No cloud dependencies
- **Privacy** - All data stored locally
- **User Control** - Enable/disable, customize time
- **Cross-Platform** - Works on iOS, Android, desktop
- **Testable** - Repository pattern enables mocking

### Negative

- **Platform Limitations** - iOS requires permission, Android varies by version
- **No Cloud Sync** - Settings don't sync across devices
- **Manual Testing** - Requires waiting for scheduled time

### Neutral

- **Local Only** - Could add cloud sync in future
- **Single Notification** - Could add multiple reminders later

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - INotificationRepository abstraction
- [ADR-0008: Notification Initialization](0008-notification-service-initialization.md) - Initialization strategy

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Service: `lib/application/services/notifications/notification_service.dart`
- Manager: `lib/application/services/notifications/notification_manager.dart`
- Repository: `lib/application/repositories/notification_repository.dart`
- Package: `flutter_local_notifications` ^18.0.1
