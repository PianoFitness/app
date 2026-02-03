import "package:piano_fitness/application/models/notification_settings.dart";

/// Interface for NotificationManager to enable dependency injection and testing.
///
/// This abstraction allows SettingsRepositoryImpl to depend on an interface
/// rather than concrete static methods, improving testability.
abstract class INotificationManager {
  /// Loads notification settings from persistent storage.
  Future<NotificationSettings> loadSettings();

  /// Saves notification settings to persistent storage.
  Future<void> saveSettings(NotificationSettings settings);

  /// Stores metadata about a scheduled notification.
  Future<void> saveScheduledNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime, {
    bool isRecurring = false,
    String? payload,
  });

  /// Removes metadata about a scheduled notification.
  Future<void> removeScheduledNotification(int id);

  /// Gets metadata about all scheduled notifications.
  Future<Map<String, dynamic>> getScheduledNotifications();

  /// Clears all scheduled notification metadata.
  Future<void> clearAllScheduledNotifications();

  /// Clears all stored notification data.
  Future<void> clearAllData();
}
