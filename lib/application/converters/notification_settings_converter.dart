import "package:flutter/material.dart";
import "package:piano_fitness/application/models/notification_settings.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";

/// Conversion helpers between domain and application notification settings models.
///
/// The domain model uses core Dart types (int for hour/minute) while the
/// application model uses Flutter's TimeOfDay for UI integration.
class NotificationSettingsConverter {
  /// Convert domain model to application model (with Flutter's TimeOfDay).
  static NotificationSettings toApplicationModel(
    NotificationSettingsData data,
  ) {
    TimeOfDay? timeOfDay;
    if (data.dailyReminderHour != null && data.dailyReminderMinute != null) {
      timeOfDay = TimeOfDay(
        hour: data.dailyReminderHour!,
        minute: data.dailyReminderMinute!,
      );
    }

    return NotificationSettings(
      practiceRemindersEnabled: data.practiceRemindersEnabled,
      dailyReminderTime: timeOfDay,
      timerCompletionEnabled: data.timerCompletionEnabled,
      permissionGranted: data.permissionGranted,
    );
  }

  /// Convert application model to domain model (with int hour/minute).
  static NotificationSettingsData toDomainModel(NotificationSettings settings) {
    return NotificationSettingsData(
      practiceRemindersEnabled: settings.practiceRemindersEnabled,
      dailyReminderHour: settings.dailyReminderTime?.hour,
      dailyReminderMinute: settings.dailyReminderTime?.minute,
      timerCompletionEnabled: settings.timerCompletionEnabled,
      permissionGranted: settings.permissionGranted,
    );
  }
}
