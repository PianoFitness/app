import "package:flutter/foundation.dart";
import "package:piano_fitness/application/converters/notification_settings_converter.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";

/// Implementation of ISettingsRepository wrapping NotificationManager
///
/// Provides instance-based access to settings persistence.
/// Converts between domain models (NotificationSettingsData) and
/// application models (NotificationSettings with Flutter types).
class SettingsRepositoryImpl implements ISettingsRepository {
  @override
  Future<NotificationSettingsData> loadNotificationSettings() async {
    try {
      final appSettings = await NotificationManager.loadSettings();
      return NotificationSettingsConverter.toDomainModel(appSettings);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error loading notification settings: $e");
        print(stackTrace);
      }
      // Return default settings on error
      return const NotificationSettingsData();
    }
  }

  @override
  Future<void> saveNotificationSettings(
    NotificationSettingsData settings,
  ) async {
    try {
      final appSettings = NotificationSettingsConverter.toApplicationModel(
        settings,
      );
      await NotificationManager.saveSettings(appSettings);
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
          .map((n) {
            try {
              final scheduledTime = DateTime.tryParse(
                n["scheduledTime"] as String? ?? "",
              );
              if (scheduledTime == null) return null;
              return ScheduledNotificationData(
                id: n["id"] as int,
                title: n["title"] as String,
                body: n["body"] as String,
                scheduledTime: scheduledTime,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<ScheduledNotificationData>()
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
