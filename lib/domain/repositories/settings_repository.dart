import "package:piano_fitness/domain/models/notification_settings_data.dart";

/// Repository interface for settings persistence
///
/// Handles saving and loading application settings including
/// notification preferences and scheduled notifications.
abstract class ISettingsRepository {
  /// Load notification settings from persistent storage
  Future<NotificationSettingsData> loadNotificationSettings();

  /// Save notification settings to persistent storage
  Future<void> saveNotificationSettings(NotificationSettingsData settings);

  /// Save scheduled notification metadata
  Future<void> saveScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });

  /// Get list of saved scheduled notifications
  Future<List<ScheduledNotificationData>> getScheduledNotifications();

  /// Remove scheduled notification metadata
  Future<void> removeScheduledNotification(int id);
}

/// Scheduled notification metadata
class ScheduledNotificationData {
  ScheduledNotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
}
