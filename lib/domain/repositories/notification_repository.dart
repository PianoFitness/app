/// Repository interface for notification operations
///
/// Handles local notification scheduling, permission management,
/// and notification display.
abstract class INotificationRepository {
  /// Notification ID used for daily practice reminders
  int get dailyReminderNotificationId;

  /// Request notification permissions from user
  Future<bool> requestPermissions();

  /// Check if notification permissions are currently granted
  Future<bool> arePermissionsGranted();

  /// Schedule daily notification at specified time
  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  });

  /// Show immediate notification
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  });

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id);

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications();

  /// Get list of pending notifications
  Future<List<PendingNotification>> getPendingNotifications();
}

/// Pending notification information
class PendingNotification {
  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => Object.hash(id, title, body);
}
