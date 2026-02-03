import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/models/notification_settings.dart";
import "package:piano_fitness/application/repositories/settings_repository_impl.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("SettingsRepositoryImpl", () {
    late MockINotificationManager mockNotificationManager;
    late SettingsRepositoryImpl repository;

    setUp(() {
      mockNotificationManager = MockINotificationManager();
      repository = SettingsRepositoryImpl(
        notificationManager: mockNotificationManager,
      );
    });

    group("loadNotificationSettings", () {
      test("converts application model to domain model", () async {
        // Arrange
        final appSettings = NotificationSettings(
          practiceRemindersEnabled: true,
          dailyReminderTime: const TimeOfDay(hour: 9, minute: 0),
          permissionGranted: true,
        );
        when(
          mockNotificationManager.loadSettings(),
        ).thenAnswer((_) async => appSettings);

        // Act
        final result = await repository.loadNotificationSettings();

        // Assert
        expect(result.practiceRemindersEnabled, true);
        expect(result.dailyReminderHour, 9);
        expect(result.dailyReminderMinute, 0);
        expect(result.timerCompletionEnabled, false);
        expect(result.permissionGranted, true);
        verify(mockNotificationManager.loadSettings()).called(1);
      });

      test("returns default settings on error", () async {
        // Arrange
        when(
          mockNotificationManager.loadSettings(),
        ).thenThrow(Exception("Storage error"));

        // Act
        final result = await repository.loadNotificationSettings();

        // Assert
        expect(result, const NotificationSettingsData());
        verify(mockNotificationManager.loadSettings()).called(1);
      });
    });

    group("saveNotificationSettings", () {
      test("converts domain model to application model and saves", () async {
        // Arrange
        final domainSettings = NotificationSettingsData(
          practiceRemindersEnabled: true,
          dailyReminderHour: 10,
          dailyReminderMinute: 30,
          timerCompletionEnabled: true,
          permissionGranted: true,
        );
        when(
          mockNotificationManager.saveSettings(any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.saveNotificationSettings(domainSettings);

        // Assert
        final captured =
            verify(
                  mockNotificationManager.saveSettings(captureAny),
                ).captured.single
                as NotificationSettings;
        expect(captured.practiceRemindersEnabled, true);
        expect(captured.dailyReminderTime?.hour, 10);
        expect(captured.dailyReminderTime?.minute, 30);
        expect(captured.timerCompletionEnabled, true);
        expect(captured.permissionGranted, true);
      });

      test("rethrows error on save failure", () async {
        // Arrange
        final domainSettings = const NotificationSettingsData();
        when(
          mockNotificationManager.saveSettings(any),
        ).thenThrow(Exception("Save error"));

        // Act & Assert
        expect(
          () => repository.saveNotificationSettings(domainSettings),
          throwsException,
        );
        verify(mockNotificationManager.saveSettings(any)).called(1);
      });
    });

    group("saveScheduledNotification", () {
      test("delegates to notification manager", () async {
        // Arrange
        final scheduledTime = DateTime(2026, 2, 3, 10);
        when(
          mockNotificationManager.saveScheduledNotification(any, any, any, any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.saveScheduledNotification(
          id: 1,
          title: "Practice Reminder",
          body: "Time to practice!",
          scheduledTime: scheduledTime,
        );

        // Assert
        verify(
          mockNotificationManager.saveScheduledNotification(
            1,
            "Practice Reminder",
            "Time to practice!",
            scheduledTime,
          ),
        ).called(1);
      });

      test("rethrows error on failure", () async {
        // Arrange
        when(
          mockNotificationManager.saveScheduledNotification(any, any, any, any),
        ).thenThrow(Exception("Save error"));

        // Act & Assert
        expect(
          () => repository.saveScheduledNotification(
            id: 1,
            title: "Test",
            body: "Test body",
            scheduledTime: DateTime.now(),
          ),
          throwsException,
        );
      });
    });

    group("getScheduledNotifications", () {
      test("parses scheduled notifications correctly", () async {
        // Arrange
        final scheduledTime = DateTime(2026, 2, 3, 10);
        when(mockNotificationManager.getScheduledNotifications()).thenAnswer(
          (_) async => {
            "1": {
              "id": 1,
              "title": "Practice Reminder",
              "body": "Time to practice!",
              "scheduledTime": scheduledTime.toIso8601String(),
            },
          },
        );

        // Act
        final result = await repository.getScheduledNotifications();

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 1);
        expect(result[0].title, "Practice Reminder");
        expect(result[0].body, "Time to practice!");
        expect(result[0].scheduledTime, scheduledTime);
        verify(mockNotificationManager.getScheduledNotifications()).called(1);
      });

      test("filters out invalid notifications", () async {
        // Arrange
        when(mockNotificationManager.getScheduledNotifications()).thenAnswer(
          (_) async => {
            "1": {
              "id": 1,
              "title": "Valid",
              "body": "Valid body",
              "scheduledTime": DateTime.now().toIso8601String(),
            },
            "2": {
              "id": 2,
              "title": "Invalid",
              "body": "Invalid body",
              "scheduledTime": "invalid-date",
            },
          },
        );

        // Act
        final result = await repository.getScheduledNotifications();

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 1);
      });

      test("returns empty list on error", () async {
        // Arrange
        when(
          mockNotificationManager.getScheduledNotifications(),
        ).thenThrow(Exception("Load error"));

        // Act
        final result = await repository.getScheduledNotifications();

        // Assert
        expect(result, isEmpty);
        verify(mockNotificationManager.getScheduledNotifications()).called(1);
      });
    });

    group("removeScheduledNotification", () {
      test("delegates to notification manager", () async {
        // Arrange
        when(
          mockNotificationManager.removeScheduledNotification(any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.removeScheduledNotification(1);

        // Assert
        verify(
          mockNotificationManager.removeScheduledNotification(1),
        ).called(1);
      });

      test("rethrows error on failure", () async {
        // Arrange
        when(
          mockNotificationManager.removeScheduledNotification(any),
        ).thenThrow(Exception("Remove error"));

        // Act & Assert
        expect(
          () => repository.removeScheduledNotification(1),
          throwsException,
        );
      });
    });
  });
}
