import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/models/notification_settings.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  group("NotificationManager", () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // Clean up after each test
      await NotificationManager.instance.clearAllData();
    });

    group("Settings Management", () {
      testWidgets("should load default settings when none exist", (
        tester,
      ) async {
        final settings = await NotificationManager.instance.loadSettings();

        expect(settings.practiceRemindersEnabled, isFalse);
        expect(settings.dailyReminderTime, isNull);
        expect(settings.timerCompletionEnabled, isFalse);
        expect(settings.permissionGranted, isFalse);
      });

      testWidgets("should save and load settings correctly", (tester) async {
        final testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: const TimeOfDay(hour: 9, minute: 30),
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);
        final loadedSettings = await NotificationManager.instance
            .loadSettings();

        expect(loadedSettings.practiceRemindersEnabled, isTrue);
        expect(loadedSettings.dailyReminderTime?.hour, equals(9));
        expect(loadedSettings.dailyReminderTime?.minute, equals(30));
        expect(loadedSettings.timerCompletionEnabled, isTrue);
        expect(loadedSettings.permissionGranted, isTrue);
      });

      testWidgets("should handle corrupted settings data gracefully", (
        tester,
      ) async {
        // Manually insert corrupted data
        SharedPreferences.setMockInitialValues({
          "notification_settings": "invalid json",
        });

        final settings = await NotificationManager.instance.loadSettings();

        // Should return default settings when data is corrupted
        expect(settings.practiceRemindersEnabled, isFalse);
        expect(settings.dailyReminderTime, isNull);
        expect(settings.timerCompletionEnabled, isFalse);
        expect(settings.permissionGranted, isFalse);
      });

      testWidgets("should handle partial settings data", (tester) async {
        // Insert partial data to test defaults for missing fields
        SharedPreferences.setMockInitialValues({
          "notification_settings": '{"practiceRemindersEnabled": true}',
        });

        final settings = await NotificationManager.instance.loadSettings();

        expect(settings.practiceRemindersEnabled, isTrue);
        expect(settings.dailyReminderTime, isNull); // Should default to null
        expect(
          settings.timerCompletionEnabled,
          isFalse,
        ); // Should default to false
        expect(settings.permissionGranted, isFalse); // Should default to false
      });

      testWidgets("should handle null time correctly", (tester) async {
        const testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);
        final loadedSettings = await NotificationManager.instance
            .loadSettings();

        expect(loadedSettings.practiceRemindersEnabled, isTrue);
        expect(loadedSettings.dailyReminderTime, isNull);
        expect(loadedSettings.timerCompletionEnabled, isFalse);
        expect(loadedSettings.permissionGranted, isTrue);
      });
    });

    group("TimeOfDay JSON Conversion", () {
      testWidgets("should convert TimeOfDay to JSON and back correctly", (
        tester,
      ) async {
        const testTime = TimeOfDay(hour: 14, minute: 45);

        final testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: testTime,
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);
        final loadedSettings = await NotificationManager.instance
            .loadSettings();

        expect(loadedSettings.dailyReminderTime?.hour, equals(14));
        expect(loadedSettings.dailyReminderTime?.minute, equals(45));
      });

      testWidgets("should handle edge case times correctly", (tester) async {
        // Test midnight
        const midnight = TimeOfDay(hour: 0, minute: 0);
        var testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: midnight,
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);
        var loadedSettings = await NotificationManager.instance.loadSettings();

        expect(loadedSettings.dailyReminderTime?.hour, equals(0));
        expect(loadedSettings.dailyReminderTime?.minute, equals(0));

        // Test end of day
        const endOfDay = TimeOfDay(hour: 23, minute: 59);
        testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: endOfDay,
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);
        loadedSettings = await NotificationManager.instance.loadSettings();

        expect(loadedSettings.dailyReminderTime?.hour, equals(23));
        expect(loadedSettings.dailyReminderTime?.minute, equals(59));
      });

      testWidgets("should handle invalid time JSON gracefully", (tester) async {
        // Manually insert invalid time data - NotificationManager now handles this gracefully
        // rather than throwing exceptions, returning default settings instead
        SharedPreferences.setMockInitialValues({
          "notification_settings":
              '{"practiceRemindersEnabled": true, "dailyReminderTime": {"hour": 25, "minute": 30}}',
        });

        final settings = await NotificationManager.instance.loadSettings();

        // Should return defaults when time parsing fails
        expect(settings.practiceRemindersEnabled, isFalse);
        expect(settings.dailyReminderTime, isNull);
      });

      testWidgets("should handle negative time values gracefully", (
        tester,
      ) async {
        // Manually insert negative time data
        SharedPreferences.setMockInitialValues({
          "notification_settings":
              '{"practiceRemindersEnabled": true, "dailyReminderTime": {"hour": -1, "minute": 30}}',
        });

        final settings = await NotificationManager.instance.loadSettings();

        // Should return defaults when time parsing fails
        expect(settings.practiceRemindersEnabled, isFalse);
        expect(settings.dailyReminderTime, isNull);
      });

      testWidgets("should handle missing time fields gracefully", (
        tester,
      ) async {
        // Manually insert incomplete time data
        SharedPreferences.setMockInitialValues({
          "notification_settings":
              '{"practiceRemindersEnabled": true, "dailyReminderTime": {"hour": 10}}',
        });

        final settings = await NotificationManager.instance.loadSettings();

        // Should return defaults when time parsing fails
        expect(settings.practiceRemindersEnabled, isFalse);
        expect(settings.dailyReminderTime, isNull);
      });

      testWidgets("should handle non-integer time values", (tester) async {
        // Manually insert string-based time data
        SharedPreferences.setMockInitialValues({
          "notification_settings":
              '{"practiceRemindersEnabled": true, "dailyReminderTime": {"hour": "10", "minute": "30"}}',
        });

        final settings = await NotificationManager.instance.loadSettings();

        // Should successfully parse string numbers
        expect(settings.dailyReminderTime?.hour, equals(10));
        expect(settings.dailyReminderTime?.minute, equals(30));
      });
    });

    group("Scheduled Notification Metadata", () {
      testWidgets("should save and retrieve scheduled notification metadata", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        await NotificationManager.instance.saveScheduledNotification(
          123,
          "Test Title",
          "Test Body",
          scheduledTime,
          payload: "test_payload",
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();

        expect(storedNotifications.containsKey("123"), isTrue);

        final notification = storedNotifications["123"]!;
        expect(notification["id"], equals(123));
        expect(notification["title"], equals("Test Title"));
        expect(notification["body"], equals("Test Body"));
        expect(
          notification["scheduledTime"],
          equals(scheduledTime.toIso8601String()),
        );
        expect(notification["isRecurring"], isFalse);
        expect(notification["payload"], equals("test_payload"));
        expect(notification["createdAt"], isNotNull);
      });

      testWidgets("should handle recurring notification metadata", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        await NotificationManager.instance.saveScheduledNotification(
          456,
          "Recurring Test",
          "Recurring Body",
          scheduledTime,
          isRecurring: true,
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["456"]!;

        expect(notification["isRecurring"], isTrue);
        expect(notification["payload"], isNull); // No payload provided
      });

      testWidgets("should warn when overwriting existing notification", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        // Save first notification
        await NotificationManager.instance.saveScheduledNotification(
          789,
          "First Title",
          "First Body",
          scheduledTime,
        );

        // Overwrite with second notification (should log warning)
        await NotificationManager.instance.saveScheduledNotification(
          789,
          "Second Title",
          "Second Body",
          scheduledTime,
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["789"]!;

        // Should have the second notification's data
        expect(notification["title"], equals("Second Title"));
        expect(notification["body"], equals("Second Body"));
      });

      testWidgets("should remove scheduled notification metadata", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        await NotificationManager.instance.saveScheduledNotification(
          999,
          "To Remove",
          "Remove Body",
          scheduledTime,
        );

        // Verify it exists
        var storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications.containsKey("999"), isTrue);

        // Remove it
        await NotificationManager.instance.removeScheduledNotification(999);

        // Verify it's gone
        storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications.containsKey("999"), isFalse);
      });

      testWidgets(
        "should handle removing non-existent notification gracefully",
        (tester) async {
          // Should not throw when removing non-existent notification
          await NotificationManager.instance.removeScheduledNotification(999);

          final storedNotifications = await NotificationManager.instance
              .getScheduledNotifications();
          expect(storedNotifications, isEmpty);
        },
      );

      testWidgets("should clear all scheduled notification metadata", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        // Add multiple notifications
        await NotificationManager.instance.saveScheduledNotification(
          111,
          "Test 1",
          "Body 1",
          scheduledTime,
        );
        await NotificationManager.instance.saveScheduledNotification(
          222,
          "Test 2",
          "Body 2",
          scheduledTime,
        );
        await NotificationManager.instance.saveScheduledNotification(
          333,
          "Test 3",
          "Body 3",
          scheduledTime,
        );

        // Verify they exist
        var storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications, hasLength(3));

        // Clear all
        await NotificationManager.instance.clearAllScheduledNotifications();

        // Verify they're all gone
        storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        expect(storedNotifications, isEmpty);
      });

      testWidgets("should handle corrupted scheduled notification data", (
        tester,
      ) async {
        // Manually insert corrupted data
        SharedPreferences.setMockInitialValues({
          "scheduled_notifications": "invalid json",
        });

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();

        // Should return empty map when data is corrupted
        expect(storedNotifications, isEmpty);
      });

      testWidgets("should handle missing scheduled notification data", (
        tester,
      ) async {
        // No data exists yet
        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();

        expect(storedNotifications, isEmpty);
      });
    });

    group("Data Management", () {
      testWidgets("should clear all notification data", (tester) async {
        // Set up some data
        final testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: const TimeOfDay(hour: 9, minute: 30),
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        await NotificationManager.instance.saveSettings(testSettings);

        await NotificationManager.instance.saveScheduledNotification(
          555,
          "Test Notification",
          "Test Body",
          DateTime.now().add(const Duration(hours: 1)),
        );

        // Verify data exists
        var settings = await NotificationManager.instance.loadSettings();
        var notifications = await NotificationManager.instance
            .getScheduledNotifications();

        expect(settings.practiceRemindersEnabled, isTrue);
        expect(notifications.containsKey("555"), isTrue);

        // Clear all data
        await NotificationManager.instance.clearAllData();

        // Verify everything is cleared
        settings = await NotificationManager.instance.loadSettings();
        notifications = await NotificationManager.instance
            .getScheduledNotifications();

        expect(settings.practiceRemindersEnabled, isFalse); // Back to defaults
        expect(notifications, isEmpty);
      });

      testWidgets("should handle save settings error gracefully", (
        tester,
      ) async {
        // This test is tricky since SharedPreferences.setString rarely fails
        // In a real scenario, you'd mock SharedPreferences to throw an error
        // For now, we just verify the method doesn't crash with valid input

        final testSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: const TimeOfDay(hour: 9, minute: 30),
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        // Should not throw
        await NotificationManager.instance.saveSettings(testSettings);

        final loadedSettings = await NotificationManager.instance
            .loadSettings();
        expect(loadedSettings.practiceRemindersEnabled, isTrue);
      });
    });

    group("Edge Cases and Error Handling", () {
      testWidgets("should handle extreme DateTime values", (tester) async {
        // Test with far future date
        final farFuture = DateTime(2100, 12, 31, 23, 59, 59);

        await NotificationManager.instance.saveScheduledNotification(
          777,
          "Far Future",
          "Future Body",
          farFuture,
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["777"]!;

        expect(
          notification["scheduledTime"],
          equals(farFuture.toIso8601String()),
        );
      });

      testWidgets("should handle empty strings in notification data", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        await NotificationManager.instance.saveScheduledNotification(
          888,
          "", // Empty title
          "", // Empty body
          scheduledTime,
          payload: "", // Empty payload
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["888"]!;

        expect(notification["title"], equals(""));
        expect(notification["body"], equals(""));
        expect(notification["payload"], equals(""));
      });

      testWidgets("should handle very long strings in notification data", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        final longString = List.filled(
          1000,
          "A",
        ).join(); // 1000 character string

        await NotificationManager.instance.saveScheduledNotification(
          999,
          longString,
          longString,
          scheduledTime,
          payload: longString,
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["999"]!;

        expect(notification["title"], equals(longString));
        expect(notification["body"], equals(longString));
        expect(notification["payload"], equals(longString));
      });

      testWidgets("should handle special characters in notification data", (
        tester,
      ) async {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        const specialChars = "🎵🎹💪 Special chars: àáâãäå ñ çß ¡¿";

        await NotificationManager.instance.saveScheduledNotification(
          1000,
          specialChars,
          specialChars,
          scheduledTime,
          payload: specialChars,
        );

        final storedNotifications = await NotificationManager.instance
            .getScheduledNotifications();
        final notification = storedNotifications["1000"]!;

        expect(notification["title"], equals(specialChars));
        expect(notification["body"], equals(specialChars));
        expect(notification["payload"], equals(specialChars));
      });
    });
  });
}
