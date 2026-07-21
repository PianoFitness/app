import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tz_data;
import "package:piano_fitness/application/services/notifications/notification_service.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";

/// Simple test spy to track plugin method calls
class NotificationPluginSpy {
  final List<String> methodCalls = [];
  bool initializeWasCalled = false;
  bool shouldThrowOnInitialize = false;

  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    methodCalls.add("initialize");
    initializeWasCalled = true;
    if (shouldThrowOnInitialize) {
      throw Exception("Test initialization failure");
    }
    return true;
  }

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    methodCalls.add("show($id, $title)");
  }

  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    AndroidScheduleMode? androidScheduleMode,
  }) async {
    methodCalls.add("zonedSchedule($id, $title)");
  }

  Future<void> cancel(int id, {String? tag}) async {
    methodCalls.add("cancel($id)");
  }

  Future<void> cancelAll() async {
    methodCalls.add("cancelAll");
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    methodCalls.add("pendingNotificationRequests");
    return [];
  }
}

void main() {
  late NotificationPluginSpy pluginSpy;

  setUpAll(() async {
    tz_data.initializeTimeZones();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pluginSpy = NotificationPluginSpy();
    NotificationService.setPluginForTesting(pluginSpy);
  });

  tearDown(() async {
    await NotificationManager.instance.clearAllData();
  });

  test("NotificationService calls plugin initialize method", () async {
    expect(pluginSpy.initializeWasCalled, false);

    await NotificationService.initialize();

    expect(pluginSpy.initializeWasCalled, true);
    expect(pluginSpy.methodCalls, contains("initialize"));
    expect(NotificationService.isInitialized, true);
  });

  test(
    "NotificationService handles plugin initialization failure gracefully",
    () async {
      pluginSpy.shouldThrowOnInitialize = true;

      await NotificationService.initialize();

      expect(pluginSpy.initializeWasCalled, true);
      expect(NotificationService.isInitialized, false);
    },
  );

  test(
    "NotificationService showInstantNotification delegates to plugin",
    () async {
      await NotificationService.initialize();
      await NotificationService.showInstantNotification(
        id: 2,
        title: "Instant Title",
        body: "Instant Body",
      );
      expect(pluginSpy.methodCalls, contains("show(2, Instant Title)"));
    },
  );

  test("NotificationService scheduleNotification for future time", () async {
    await NotificationService.initialize();
    final futureTime = DateTime.now().add(const Duration(hours: 1));

    await NotificationService.scheduleNotification(
      id: 50,
      title: "Future Event",
      body: "Scheduled Event Body",
      scheduledTime: futureTime,
    );

    expect(
      pluginSpy.methodCalls.any((call) => call.contains("zonedSchedule(50")),
      isTrue,
    );
  });

  test(
    "NotificationService cancelNotification and cancelAllNotifications delegate to plugin",
    () async {
      await NotificationService.initialize();
      await NotificationService.cancelNotification(1);
      expect(pluginSpy.methodCalls, contains("cancel(1)"));

      await NotificationService.cancelAllNotifications();
      expect(pluginSpy.methodCalls, contains("cancelAll"));
    },
  );

  test(
    "NotificationService scheduleDailyNotification schedules recurring daily notification",
    () async {
      await NotificationService.initialize();
      final futureTime = DateTime.now().add(const Duration(hours: 2));

      await NotificationService.scheduleDailyNotification(
        title: "Daily Practice",
        body: "Time to play!",
        time: futureTime,
      );

      expect(
        pluginSpy.methodCalls.any((call) => call.contains("zonedSchedule")),
        isTrue,
      );
    },
  );

  test(
    "NotificationService requestPermissions and arePermissionsGranted execute cleanly",
    () async {
      final granted = await NotificationService.requestPermissions();
      expect(granted, isA<bool>());

      final check = await NotificationService.arePermissionsGranted();
      expect(check, isA<bool>());
    },
  );

  test(
    "Uninitialized NotificationService methods log warning and return early",
    () async {
      await NotificationService.showInstantNotification(title: "T", body: "B");
      await NotificationService.scheduleNotification(
        id: 1,
        title: "T",
        body: "B",
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
      await NotificationService.scheduleDailyNotification(
        title: "T",
        body: "B",
        time: DateTime.now(),
      );
      await NotificationService.cancelNotification(1);
      await NotificationService.cancelAllNotifications();

      expect(pluginSpy.methodCalls, isEmpty);
    },
  );

  group("Data Cleanup Logic", () {
    test(
      "NotificationService sync logic should handle stale notification cleanup",
      () async {
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await NotificationManager.instance.saveScheduledNotification(
          100,
          "Past Notification",
          "Should be cleaned up",
          pastTime,
        );

        await NotificationManager.instance.saveScheduledNotification(
          200,
          "Future Notification",
          "Should remain",
          futureTime,
        );

        var storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications.length, 2);

        final now = DateTime.now();
        final toRemove = <String>[];

        for (final entry in storedNotifications.entries) {
          final notificationData = entry.value as Map<String, dynamic>;
          final scheduledTime = DateTime.parse(
            notificationData["scheduledTime"] as String,
          );
          final isRecurring = notificationData["isRecurring"] as bool? ?? false;

          if (scheduledTime.isBefore(now) && !isRecurring) {
            toRemove.add(entry.key);
          }
        }

        for (final id in toRemove) {
          await NotificationManager.instance.removeScheduledNotification(
            int.parse(id),
          );
        }

        storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications.containsKey("100"), false);
        expect(storedNotifications.containsKey("200"), true);
      },
    );

    test(
      "NotificationManager should handle corrupted data gracefully",
      () async {
        SharedPreferences.setMockInitialValues({
          "scheduled_notifications": "invalid json data",
        });

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications.isEmpty, true);
      },
    );
  });
}
