import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/notification_repository_impl.dart";
import "package:piano_fitness/application/services/notifications/notification_service.dart";

class FakePlugin {
  bool initialized = false;
  bool permissionsGranted = true;

  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
  }) async {
    initialized = true;
    return true;
  }

  Future<bool?> requestPermissions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    return permissionsGranted;
  }

  Future<void> show(
    int id,
    String? title,
    String? body,
    dynamic notificationDetails, {
    String? payload,
  }) async {}
  Future<void> cancel(int id) async {}
  Future<void> cancelAll() async {}
  Future<dynamic> zonedSchedule(
    int id,
    String? title,
    String? body,
    dynamic scheduledDate,
    dynamic notificationDetails, {
    required dynamic uiLocalNotificationDateInterpretation,
    required bool androidScheduleMode,
    String? payload,
    dynamic matchDateTimeComponents,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("NotificationRepositoryImpl Tests", () {
    late FakePlugin fakePlugin;

    setUp(() {
      fakePlugin = FakePlugin();
      NotificationService.setPluginForTesting(fakePlugin);
    });

    test("create factory initializes repository cleanly", () async {
      final repo = await NotificationRepositoryImpl.create();
      expect(repo, isNotNull);
      expect(
        repo.dailyReminderNotificationId,
        equals(NotificationService.dailyReminderNotificationId),
      );
    });

    test("arePermissionsGranted returns expected bool", () async {
      final repo = await NotificationRepositoryImpl.create();
      final granted = await repo.arePermissionsGranted();
      expect(granted, isA<bool>());
    });

    test("requestPermissions delegates to NotificationService", () async {
      final repo = await NotificationRepositoryImpl.create();
      final result = await repo.requestPermissions();
      expect(result, isA<bool>());
    });

    test("scheduleDailyNotification executes without throwing", () async {
      final repo = await NotificationRepositoryImpl.create();
      await repo.scheduleDailyNotification(
        title: "Daily Practice",
        body: "Time to play piano!",
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
    });

    test("showInstantNotification executes without throwing", () async {
      final repo = await NotificationRepositoryImpl.create();
      await repo.showInstantNotification(
        id: 1,
        title: "Goal Achieved",
        body: "Well done!",
      );
    });

    test(
      "cancelNotification and cancelAllNotifications execute cleanly",
      () async {
        final repo = await NotificationRepositoryImpl.create();
        await repo.cancelNotification(1);
        await repo.cancelAllNotifications();
      },
    );

    test("getPendingNotifications returns list", () async {
      final repo = await NotificationRepositoryImpl.create();
      final pending = await repo.getPendingNotifications();
      expect(pending, isEmpty);
    });
  });
}
