import "package:flutter/material.dart";

/// Model representing user notification preferences and settings.
///
/// This class encapsulates all notification-related settings including
/// permission status, enabled features, and scheduling preferences.
class NotificationSettings {
  /// Creates a new NotificationSettings instance.
  const NotificationSettings({
    this.practiceRemindersEnabled = false,
    this.dailyReminderTime,
    this.timerCompletionEnabled = false,
    this.permissionGranted = false,
  });

  /// Whether daily practice reminder notifications are enabled.
  final bool practiceRemindersEnabled;

  /// The time of day for daily practice reminders.
  /// Null if practice reminders are disabled.
  final TimeOfDay? dailyReminderTime;

  /// Whether timer completion notifications are enabled.
  final bool timerCompletionEnabled;

  /// Whether notification permissions have been granted by the user.
  final bool permissionGranted;

  /// Whether any notifications are enabled.
  bool get hasAnyNotificationsEnabled =>
      practiceRemindersEnabled || timerCompletionEnabled;

  /// Creates a copy of this settings with the given fields replaced.
  NotificationSettings copyWith({
    bool? practiceRemindersEnabled,
    TimeOfDay? dailyReminderTime,
    bool? timerCompletionEnabled,
    bool? permissionGranted,
  }) {
    return NotificationSettings(
      practiceRemindersEnabled:
          practiceRemindersEnabled ?? this.practiceRemindersEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      timerCompletionEnabled:
          timerCompletionEnabled ?? this.timerCompletionEnabled,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }

  /// Creates a NotificationSettings instance with daily reminder time cleared.
  NotificationSettings clearDailyReminderTime() {
    return NotificationSettings(
      timerCompletionEnabled: timerCompletionEnabled,
      permissionGranted: permissionGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          practiceRemindersEnabled == other.practiceRemindersEnabled &&
          dailyReminderTime == other.dailyReminderTime &&
          timerCompletionEnabled == other.timerCompletionEnabled &&
          permissionGranted == other.permissionGranted;

  @override
  int get hashCode =>
      practiceRemindersEnabled.hashCode ^
      dailyReminderTime.hashCode ^
      timerCompletionEnabled.hashCode ^
      permissionGranted.hashCode;

  @override
  String toString() {
    return "NotificationSettings("
        "practiceRemindersEnabled: $practiceRemindersEnabled, "
        "dailyReminderTime: $dailyReminderTime, "
        "timerCompletionEnabled: $timerCompletionEnabled, "
        "permissionGranted: $permissionGranted)";
  }
}
