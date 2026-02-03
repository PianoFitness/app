import "package:flutter/foundation.dart";
import "package:piano_fitness/application/models/notification_settings.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";

/// Implementation of ISettingsRepository wrapping NotificationManager
///
/// Provides instance-based access to settings persistence.
class SettingsRepositoryImpl implements ISettingsRepository {
  @override
  Future<NotificationSettings> loadNotificationSettings() async {
    try {
      return await NotificationManager.loadSettings();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error loading notification settings: $e");
        print(stackTrace);
      }
      // Return default settings on error
      return const NotificationSettings();
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      await NotificationManager.saveSettings(settings);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error saving notification settings: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> saveScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await NotificationManager.saveScheduledNotification(
        id,
        title,
        body,
        scheduledTime,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error saving scheduled notification: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<List<ScheduledNotificationData>> getScheduledNotifications() async {
    try {
      final notificationsMap =
          await NotificationManager.getScheduledNotifications();
      return notificationsMap.values
          .map(
            (n) => ScheduledNotificationData(
              id: n["id"] as int,
              title: n["title"] as String,
              body: n["body"] as String,
              scheduledTime: DateTime.parse(n["scheduledTime"] as String),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error getting scheduled notifications: $e");
        print(stackTrace);
      }
      return [];
    }
  }

  @override
  Future<void> removeScheduledNotification(int id) async {
    try {
      await NotificationManager.removeScheduledNotification(id);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error removing scheduled notification: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }
}
