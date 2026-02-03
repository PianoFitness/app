import "package:flutter/foundation.dart";
import "package:piano_fitness/application/services/notifications/notification_service.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";

/// Implementation of INotificationRepository wrapping NotificationService
///
/// Converts static NotificationService methods to instance-based repository.
/// Use NotificationRepositoryImpl.create() to ensure async initialization completes.
class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl._();

  static Future<NotificationRepositoryImpl> create() async {
    final instance = NotificationRepositoryImpl._();
    await instance._initializeAsync();
    return instance;
  }

  Future<void> _initializeAsync() async {
    try {
      await NotificationService.initialize();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Failed to initialize NotificationService: $e");
        print(stackTrace);
      }
      // Non-fatal - app continues without notifications
    }
  }

  @override
  int get dailyReminderNotificationId =>
      NotificationService.dailyReminderNotificationId;

  @override
  Future<bool> requestPermissions() async {
    try {
      return await NotificationService.requestPermissions();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error requesting notification permissions: $e");
        print(stackTrace);
      }
      return false;
    }
  }

  @override
  Future<bool> arePermissionsGranted() async {
    try {
      return await NotificationService.arePermissionsGranted();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error checking notification permissions: $e");
        print(stackTrace);
      }
      return false;
    }
  }

  @override
  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await NotificationService.scheduleDailyNotification(
        title: title,
        body: body,
        time: scheduledTime,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error scheduling notification: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await NotificationService.showInstantNotification(
        id: id,
        title: title,
        body: body,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error showing notification: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await NotificationService.cancelNotification(id);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error canceling notification: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error canceling all notifications: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<List<PendingNotification>> getPendingNotifications() async {
    // NotificationService doesn't expose pending notifications
    // This would require enhancement in Phase 4
    return [];
  }
}
