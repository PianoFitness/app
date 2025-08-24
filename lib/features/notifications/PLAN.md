# Notifications Feature Plan - MVP

## Overview

This plan outlines the implementation of a minimal viable notifications feature for Piano Fitness. The feature will provide basic local notification capabilities to enhance user engagement and practice reminders.

## Core Requirements

### 1. System Integration

- **Plugin**: `flutter_local_notifications` (cross-platform support for macOS, iOS, web)
- **Platform Support**: macOS (primary), iOS, limited web support
- **Dependencies**: `timezone` package for scheduling

### 2. Feature Components

#### A. Notification Service (`lib/shared/services/notification_service.dart`)

- Centralized notification management
- Platform-specific permission handling
- Immediate and scheduled notification capabilities
- Integration with existing architecture patterns

#### B. Notifications Configuration Page (`lib/features/notifications/`)

- **notifications_page.dart**: Settings UI for notification preferences
- **notifications_page_view_model.dart**: Business logic and state management
- User-friendly toggles for notification types
- Time picker for daily practice reminders
- Permission request handling

#### C. Integration Points

- **Repertoire Timer**: Completion notifications when practice timer concludes
- **Daily Reminders**: Optional scheduled notifications for practice sessions
- **App Startup**: Permission prompts when notifications are first enabled

## Technical Architecture

### File Structure

```
lib/
├── features/
│   └── notifications/
│       ├── notifications_page.dart
│       ├── notifications_page_view_model.dart
│       └── widgets/
│           └── notification_permission_dialog.dart
└── shared/
    ├── models/
    │   └── notification_settings.dart
    └── services/
        └── notification_service.dart
```

### Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  flutter_local_notifications: ^17.2.3
  timezone: ^0.10.0
```

## Implementation Details

### 1. NotificationService Architecture

```dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  // Core methods:
  static Future<void> initialize()
  static Future<bool> requestPermissions()
  static Future<void> showInstantNotification({title, body})
  static Future<void> scheduleNotification({title, body, scheduledTime})
  static Future<void> cancelAllNotifications()
}
```

### 2. NotificationSettings Model

```dart
class NotificationSettings {
  final bool practiceRemindersEnabled;
  final TimeOfDay? dailyReminderTime;
  final bool timerCompletionEnabled;
  final bool permissionGranted;
}
```

### 3. Integration with Repertoire Timer

- Modify `RepertoirePageViewModel._timerCompleted()` to trigger notification
- Notification shows: "Great practice session! You completed X minutes of practice."
- Only show if user has enabled timer completion notifications

### 4. Daily Practice Reminders

- Allow users to set a preferred practice time
- Schedule recurring daily notifications
- Message: "Time to practice piano! 🎹" (emoji only if explicitly requested)
- Cancel/reschedule when time is changed

### 5. Permission Handling Strategy

- **Lazy Permission Request**: Only request when user first enables notifications
- **Clear UI Feedback**: Show permission status in settings
- **Graceful Degradation**: Disable notification options when permission denied
- **Re-request Flow**: Guide users to system settings if initially denied

## User Experience Flow

### First-Time Setup

1. User navigates to Notifications settings page
2. All notification options are disabled/grayed out initially
3. When user toggles any notification type, permission dialog appears
4. After permission granted, options become available
5. Settings are persisted locally

### Repertoire Timer Integration

1. User completes a timed practice session
2. Timer completion triggers both sound AND notification (if enabled)
3. Notification includes practice duration and encouraging message
4. Notification appears even if app is backgrounded

### Daily Reminder Setup

1. User enables daily practice reminders
2. Time picker allows selection of preferred practice time
3. Notification scheduled for selected time daily
4. User can modify or disable at any time

## Technical Considerations

### Platform-Specific Implementation

- **macOS**: Full notification support with proper permission handling
- **iOS**: Full support, requires real device testing (not simulator)
- **Web**: Limited support, requires additional JavaScript integration

### Permission Edge Cases

- Handle denied permissions gracefully
- Provide clear messaging about why permissions are needed
- Guide users to system settings for re-enabling

### State Management

- Use ChangeNotifier pattern consistent with existing ViewModels
- Store settings in SharedPreferences for persistence
- Clean notification scheduling/cancellation on settings changes

## MVP Scope Limitations

### What's Included

- Basic notification permissions and settings UI
- Repertoire timer completion notifications
- Daily practice reminder scheduling
- Simple, clean UI consistent with app design

### What's Excluded (Future Iterations)

- Rich notifications with actions or images
- Push notifications or server integration
- Advanced scheduling (weekly patterns, multiple daily reminders)
- Notification history or analytics
- Custom notification sounds
- Streak tracking or progress-based notifications

## Testing Strategy

### Unit Tests

- NotificationService core functionality
- NotificationSettings model validation
- ViewModel business logic and state management

### Widget Tests

- Notifications settings page UI components
- Permission dialog interactions
- Time picker integration

### Integration Tests

- End-to-end notification flow
- Timer completion → notification trigger
- Settings persistence and restoration

### Manual Testing Requirements

- Real device testing for iOS notifications
- macOS system notification appearance
- Permission request flow on each platform
- Background notification delivery

## Implementation Phases

### Phase 1: Foundation (Week 1)

1. Add flutter_local_notifications dependency
2. Implement basic NotificationService
3. Create NotificationSettings model
4. Set up basic project structure

### Phase 2: Configuration UI (Week 1)

1. Build notifications settings page UI
2. Implement ViewModel with permission handling
3. Add time picker for daily reminders
4. Integrate with main navigation

### Phase 3: Feature Integration (Week 2)

1. Integrate notification trigger in RepertoirePageViewModel
2. Implement daily reminder scheduling
3. Add permission request dialogs
4. Test cross-platform functionality

### Phase 4: Polish & Testing (Week 2)

1. Comprehensive testing suite
2. UI/UX refinement and accessibility
3. Error handling and edge cases
4. Documentation and code review

## Success Metrics

### Functional Success

- [ ] Permissions request and handling works on all platforms
- [ ] Timer completion notifications appear reliably
- [ ] Daily reminders can be scheduled and trigger correctly
- [ ] Settings persist across app sessions
- [ ] No crashes or performance impacts

### User Experience Success

- [ ] Settings UI is intuitive and consistent with app design
- [ ] Permission flows are clear and non-intrusive
- [ ] Notifications are helpful and not annoying
- [ ] Users can easily disable or modify notification preferences

## Future Enhancements (Post-MVP)

1. **Advanced Scheduling**: Multiple daily reminders, weekly patterns
2. **Smart Notifications**: Based on practice streaks or missed sessions
3. **Rich Notifications**: Include practice suggestions or progress updates
4. **Notification Analytics**: Track notification effectiveness and user engagement
5. **Custom Sounds**: Allow users to select notification tones
6. **Practice Session Integration**: Notifications for different practice modes completion

---

This plan provides a comprehensive roadmap for implementing notifications in Piano Fitness while maintaining the app's focus on simplicity and user experience. The MVP approach ensures we deliver core value while establishing a foundation for future enhancements.
