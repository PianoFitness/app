import "package:flutter/material.dart";
import "package:piano_fitness/application/converters/notification_settings_converter.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";

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

  /// Converts a domain [NotificationSettingsData] into an application [NotificationSettings].
  factory NotificationSettings.fromDomain(NotificationSettingsData data) {
    return NotificationSettingsConverter.toApplicationModel(data);
  }

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

  /// Converts this application model into a domain [NotificationSettingsData].
  NotificationSettingsData toDomain() {
    return NotificationSettingsConverter.toDomainModel(this);
  }

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
      practiceRemindersEnabled: practiceRemindersEnabled,
      // The argument dailyReminderTime: null, in the constructor is not redundant—it's necessary to explicitly clear the daily reminder time.
      // ignore: avoid_redundant_argument_values
      dailyReminderTime: null,
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
      (dailyReminderTime?.hashCode ?? 0) ^
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
