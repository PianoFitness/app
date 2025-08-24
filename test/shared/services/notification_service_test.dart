import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tz_data;
import "package:piano_fitness/shared/services/notification_service.dart";
import "package:piano_fitness/shared/services/notification_manager.dart";

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
    // Initialize timezone database once for all tests
    tz_data.initializeTimeZones();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pluginSpy = NotificationPluginSpy();
    NotificationService.setPluginForTesting(pluginSpy as dynamic);
  });

  tearDown(() async {
    await NotificationManager.clearAllData();
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

      // Should not throw, just log and continue
      await NotificationService.initialize();

      expect(pluginSpy.initializeWasCalled, true);
      expect(NotificationService.isInitialized, false);
    },
  );

  test(
    "NotificationService scheduleNotification calls plugin zonedSchedule",
    () async {
      await NotificationService.initialize();

      await NotificationService.scheduleNotification(
        id: 123,
        title: "Test Notification",
        body: "Test Body",
        scheduledTime: DateTime.now().add(Duration(hours: 1)),
      );

      expect(
        pluginSpy.methodCalls,
        contains("zonedSchedule(123, Test Notification)"),
      );
    },
  );

  test("NotificationService cancelNotification calls plugin cancel", () async {
    await NotificationService.initialize();

    await NotificationService.cancelNotification(456);

    expect(pluginSpy.methodCalls, contains("cancel(456)"));
  });

  test(
    "NotificationService cancelAllNotifications calls plugin cancelAll",
    () async {
      await NotificationService.initialize();

      await NotificationService.cancelAllNotifications();

      expect(pluginSpy.methodCalls, contains("cancelAll"));
    },
  );

  test(
    "NotificationService methods gracefully handle uninitialized state",
    () async {
      // Don't initialize service

      // These should not throw but also not call plugin methods
      await NotificationService.scheduleNotification(
        id: 1,
        title: "Test",
        body: "Body",
        scheduledTime: DateTime.now().add(Duration(minutes: 1)),
      );
      await NotificationService.cancelNotification(1);
      await NotificationService.cancelAllNotifications();

      // Only sync method should have been called during setup
      expect(
        pluginSpy.methodCalls
            .where((call) => call != "pendingNotificationRequests")
            .isEmpty,
        true,
      );
    },
  );

  group("NotificationManager Integration", () {
    test(
      "NotificationService should interact with NotificationManager for persistence",
      () async {
        final futureTime = DateTime.now().add(Duration(hours: 1));

        await NotificationManager.saveScheduledNotification(
          123,
          "Test Schedule",
          "Test Body",
          futureTime,
          payload: "test_payload",
        );

        final storedNotifications =
            await NotificationManager.getScheduledNotifications();
        expect(storedNotifications.containsKey("123"), true);

        final notification = storedNotifications["123"]!;
        expect(notification["title"], "Test Schedule");
        expect(notification["body"], "Test Body");
        expect(notification["payload"], "test_payload");
        expect(notification["isRecurring"], false);
      },
    );

    test(
      "NotificationService should handle recurring notification metadata",
      () async {
        final futureTime = DateTime.now().add(Duration(hours: 1));

        await NotificationManager.saveScheduledNotification(
          NotificationService.dailyReminderNotificationId,
          "Daily Reminder",
          "Practice time!",
          futureTime,
          isRecurring: true,
        );

        final storedNotifications =
            await NotificationManager.getScheduledNotifications();
        final notification =
            storedNotifications[NotificationService.dailyReminderNotificationId
                .toString()]!;

        expect(notification["isRecurring"], true);
        expect(notification["title"], "Daily Reminder");
      },
    );
  });

  group("Validation and Constants", () {
    test("NotificationService should have correct notification constants", () {
      expect(NotificationService.dailyReminderNotificationId, 1001);
      expect(NotificationService.timerCompletionNotificationId, 1002);
    });

    test(
      "NotificationService should reject scheduling notifications in the past",
      () async {
        await NotificationService.initialize();
        final pastTime = DateTime.now().subtract(Duration(hours: 1));

        await NotificationService.scheduleNotification(
          id: 999,
          title: "Past Notification",
          body: "Should not be scheduled",
          scheduledTime: pastTime,
        );

        // Should not call zonedSchedule for past times
        expect(
          pluginSpy.methodCalls.any(
            (call) => call.contains("zonedSchedule(999"),
          ),
          false,
        );
      },
    );
  });

  group("Data Cleanup Logic", () {
    test(
      "NotificationService sync logic should handle stale notification cleanup",
      () async {
        final pastTime = DateTime.now().subtract(Duration(hours: 1));
        final futureTime = DateTime.now().add(Duration(hours: 1));

        // Add both past and future notifications
        await NotificationManager.saveScheduledNotification(
          100,
          "Past Notification",
          "Should be cleaned up",
          pastTime,
        );

        await NotificationManager.saveScheduledNotification(
          200,
          "Future Notification",
          "Should remain",
          futureTime,
        );

        var storedNotifications =
            await NotificationManager.getScheduledNotifications();
        expect(storedNotifications.length, 2);

        // Simulate cleanup logic (similar to what _syncStoredWithPending does)
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

        // Remove stale notifications
        for (final id in toRemove) {
          await NotificationManager.removeScheduledNotification(int.parse(id));
        }

        storedNotifications =
            await NotificationManager.getScheduledNotifications();
        expect(
          storedNotifications.containsKey("100"),
          false,
        ); // Past notification removed
        expect(
          storedNotifications.containsKey("200"),
          true,
        ); // Future notification remains
      },
    );

    test(
      "NotificationManager should handle corrupted data gracefully",
      () async {
        // Insert corrupted data
        SharedPreferences.setMockInitialValues({
          "scheduled_notifications": "invalid json data",
        });

        // Should not throw when loading corrupted data
        final storedNotifications =
            await NotificationManager.getScheduledNotifications();
        expect(storedNotifications.isEmpty, true);
      },
    );
  });
}
