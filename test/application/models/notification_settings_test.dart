import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/models/notification_settings.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";

void main() {
  group("NotificationSettings Model Tests", () {
    test("default constructor initializes with expected defaults", () {
      const settings = NotificationSettings();
      expect(settings.practiceRemindersEnabled, isFalse);
      expect(settings.dailyReminderTime, isNull);
      expect(settings.timerCompletionEnabled, isFalse);
      expect(settings.permissionGranted, isFalse);
      expect(settings.hasAnyNotificationsEnabled, isFalse);
    });

    test(
      "hasAnyNotificationsEnabled returns true when practiceRemindersEnabled or timerCompletionEnabled is true",
      () {
        const s1 = NotificationSettings(practiceRemindersEnabled: true);
        expect(s1.hasAnyNotificationsEnabled, isTrue);

        const s2 = NotificationSettings(timerCompletionEnabled: true);
        expect(s2.hasAnyNotificationsEnabled, isTrue);
      },
    );

    test("copyWith updates fields correctly", () {
      const initial = NotificationSettings();
      const updatedTime = TimeOfDay(hour: 9, minute: 30);

      final updated = initial.copyWith(
        practiceRemindersEnabled: true,
        dailyReminderTime: updatedTime,
        timerCompletionEnabled: true,
        permissionGranted: true,
      );

      expect(updated.practiceRemindersEnabled, isTrue);
      expect(updated.dailyReminderTime, equals(updatedTime));
      expect(updated.timerCompletionEnabled, isTrue);
      expect(updated.permissionGranted, isTrue);
    });

    test("clearDailyReminderTime sets dailyReminderTime to null", () {
      const initial = NotificationSettings(
        practiceRemindersEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 10, minute: 0),
      );

      final cleared = initial.clearDailyReminderTime();
      expect(cleared.dailyReminderTime, isNull);
      expect(cleared.practiceRemindersEnabled, isTrue);
    });

    test("fromDomain and toDomain conversion", () {
      const domainData = NotificationSettingsData(
        practiceRemindersEnabled: true,
        dailyReminderHour: 18,
        dailyReminderMinute: 15,
        timerCompletionEnabled: true,
        permissionGranted: true,
      );

      final appModel = NotificationSettings.fromDomain(domainData);
      expect(appModel.practiceRemindersEnabled, isTrue);
      expect(
        appModel.dailyReminderTime,
        equals(const TimeOfDay(hour: 18, minute: 15)),
      );

      final convertedDomain = appModel.toDomain();
      expect(
        convertedDomain.practiceRemindersEnabled,
        equals(domainData.practiceRemindersEnabled),
      );
      expect(
        convertedDomain.dailyReminderHour,
        equals(domainData.dailyReminderHour),
      );
      expect(
        convertedDomain.dailyReminderMinute,
        equals(domainData.dailyReminderMinute),
      );
    });

    test("equality and hashCode", () {
      const s1 = NotificationSettings(
        practiceRemindersEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 8, minute: 0),
      );
      const s2 = NotificationSettings(
        practiceRemindersEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 8, minute: 0),
      );
      const s3 = NotificationSettings(timerCompletionEnabled: true);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });

    test("toString output format", () {
      const settings = NotificationSettings(
        practiceRemindersEnabled: true,
        permissionGranted: true,
      );

      final str = settings.toString();
      expect(str, contains("NotificationSettings"));
      expect(str, contains("practiceRemindersEnabled: true"));
    });
  });
}
