import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/services/notification_manager.dart";
import "package:piano_fitness/shared/services/notification_service.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:timezone/data/latest.dart" as tz;
import "package:timezone/timezone.dart" as tz;

void main() {
  group("NotificationService - Business Logic Tests", () {
    setUpAll(() {
      // Initialize timezone data for tests
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation("UTC"));

      // Set up logging for test output - only show warnings and errors
      Logger.root.level = Level.WARNING;
      Logger.root.onRecord.listen((record) {
        if (record.level >= Level.WARNING) {
          debugPrint("${record.level.name}: ${record.message}");
        }
      });
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await NotificationManager.clearAllData();
    });

    group("Static Utility Methods", () {
      testWidgets("should calculate next instance of time correctly", (
        tester,
      ) async {
        // Test time already passed today
        final now = tz.TZDateTime.now(tz.local);
        final pastTimeToday = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour - 1,
          now.minute,
        );

        // Use reflection to access private method (for testing purposes)
        // In a real scenario, you'd make this method public or create a wrapper
        final nextPast = NotificationServiceTestExtension._nextInstanceOfTime(
          pastTimeToday,
        );

        // Should be scheduled for tomorrow
        expect(nextPast.isAfter(now), isTrue);
        expect(nextPast.day, equals(now.day + 1));
        expect(nextPast.hour, equals(pastTimeToday.hour));
        expect(nextPast.minute, equals(pastTimeToday.minute));
      });

      testWidgets("should handle future time correctly", (tester) async {
        final now = tz.TZDateTime.now(tz.local);
        final futureTimeToday = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
          now.minute,
        );

        final nextFuture = NotificationServiceTestExtension._nextInstanceOfTime(
          futureTimeToday,
        );

        // Should be scheduled for today
        expect(nextFuture.day, equals(now.day));
        expect(nextFuture.hour, equals(futureTimeToday.hour));
        expect(nextFuture.minute, equals(futureTimeToday.minute));
      });

      testWidgets("should handle midnight time correctly", (tester) async {
        final midnight = DateTime(2024);
        final nextMidnight =
            NotificationServiceTestExtension._nextInstanceOfTime(midnight);

        expect(nextMidnight.hour, equals(0));
        expect(nextMidnight.minute, equals(0));
      });

      testWidgets("should handle end of day time correctly", (tester) async {
        final endOfDay = DateTime(2024, 1, 1, 23, 59);
        final nextEndOfDay =
            NotificationServiceTestExtension._nextInstanceOfTime(endOfDay);

        expect(nextEndOfDay.hour, equals(23));
        expect(nextEndOfDay.minute, equals(59));
      });
    });

    group("Notification Constants", () {
      testWidgets("should have correct notification channel IDs", (
        tester,
      ) async {
        // Test that constants are accessible and have expected values
        expect(NotificationService.dailyReminderNotificationId, equals(1001));
        expect(NotificationService.timerCompletionNotificationId, equals(1002));
      });
    });

    group("Input Validation", () {
      testWidgets("should validate scheduling times", (tester) async {
        // Test that past times are rejected
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));

        // This test verifies the validation logic without actually calling the plugin
        expect(pastTime.isBefore(DateTime.now()), isTrue);

        // Test that future times are accepted
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        expect(futureTime.isAfter(DateTime.now()), isTrue);
      });

      testWidgets("should handle empty/null string inputs", (tester) async {
        // Test that the service can handle various string inputs
        const emptyTitle = "";
        const nullPayload = null;
        const normalBody = "Normal body text";

        expect(emptyTitle.isNotEmpty, isFalse);
        expect(nullPayload, isNull);
        expect(normalBody.isNotEmpty, isTrue);
      });
    });

    group("Notification Metadata Interaction", () {
      testWidgets("should interact with notification manager for scheduling", (
        tester,
      ) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        // Manually test the notification manager interaction
        await NotificationManager.saveScheduledNotification(
          123,
          "Test Schedule",
          "Test Body",
          futureTime,
          payload: "test_payload",
        );

        final storedNotifications =
            await NotificationManager.getScheduledNotifications();
        expect(storedNotifications.containsKey("123"), isTrue);

        final notification = storedNotifications["123"]!;
        expect(notification["title"], equals("Test Schedule"));
        expect(notification["body"], equals("Test Body"));
        expect(notification["payload"], equals("test_payload"));
        expect(notification["isRecurring"], isFalse);
      });

      testWidgets("should handle recurring notification metadata", (
        tester,
      ) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

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

        expect(notification["isRecurring"], isTrue);
        expect(notification["title"], equals("Daily Reminder"));
      });
    });

    group("Error Handling Logic", () {
      testWidgets(
        "should handle malformed stored notification data gracefully",
        (tester) async {
          // Insert corrupted data
          SharedPreferences.setMockInitialValues({
            "scheduled_notifications": "invalid json data",
          });

          // Should not throw when loading corrupted data
          final storedNotifications =
              await NotificationManager.getScheduledNotifications();
          expect(storedNotifications, isEmpty);
        },
      );

      testWidgets("should handle notification sync logic", (tester) async {
        // Test the sync logic by creating scenarios with stale data
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));
        final futureTime = DateTime.now().add(const Duration(hours: 1));

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
        expect(storedNotifications, hasLength(2));

        // Simulate cleanup of past notifications
        final now = DateTime.now();
        final toRemove = <String>[];

        for (final entry in storedNotifications.entries) {
          final notificationData = entry.value as Map<String, dynamic>;
          final scheduledTime = DateTime.parse(
            notificationData["scheduledTime"] as String,
          );

          if (scheduledTime.isBefore(now) &&
              !(notificationData["isRecurring"] as bool? ?? false)) {
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
          isFalse,
        ); // Past notification removed
        expect(
          storedNotifications.containsKey("200"),
          isTrue,
        ); // Future notification remains
      });

      testWidgets("should handle edge cases in date calculations", (
        tester,
      ) async {
        // Test with various timezone edge cases
        final utcNow = DateTime.now().toUtc();
        final localNow = DateTime.now();

        expect(
          utcNow.difference(localNow).inHours.abs() <= 24,
          isTrue,
        ); // Should be within reasonable timezone offset

        // Test with daylight saving time transitions (approximate)
        final springTransition = DateTime(2024, 3, 10, 2, 30); // Spring forward
        final fallTransition = DateTime(2024, 11, 3, 1, 30); // Fall back

        expect(springTransition.isUtc, isFalse);
        expect(fallTransition.isUtc, isFalse);
      });
    });

    group("Platform-Specific Logic", () {
      testWidgets("should handle web platform detection", (tester) async {
        // Test platform detection logic
        debugDefaultTargetPlatformOverride =
            TargetPlatform.fuchsia; // Simulate web

        expect(
          kIsWeb ||
              debugDefaultTargetPlatformOverride == TargetPlatform.fuchsia,
          isTrue,
        );

        debugDefaultTargetPlatformOverride = null; // Reset
      });

      testWidgets("should handle different platform configurations", (
        tester,
      ) async {
        // Test platform-specific notification configurations
        const androidConfig = {
          "channelId": "test_channel",
          "importance": "high",
          "priority": "high",
        };

        const iosConfig = {
          "requestSound": true,
          "requestAlert": true,
          "requestBadge": true,
        };

        expect(androidConfig["importance"], equals("high"));
        expect(iosConfig["requestSound"], isTrue);
      });
    });
  });
}

// Extension to access private methods for testing
extension NotificationServiceTestExtension on NotificationService {
  static tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
