import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page.dart";
import "package:provider/provider.dart";

class FakeNotificationRepository implements INotificationRepository {
  @override
  int get dailyReminderNotificationId => 1;

  @override
  Future<bool> arePermissionsGranted() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsRepository implements ISettingsRepository {
  NotificationSettingsData settings = const NotificationSettingsData(
    permissionGranted: true,
    timerCompletionEnabled: true,
    dailyReminderHour: 20,
    dailyReminderMinute: 0,
  );

  @override
  Future<NotificationSettingsData> loadNotificationSettings() async => settings;

  @override
  Future<void> saveNotificationSettings(
    NotificationSettingsData newSettings,
  ) async {
    settings = newSettings;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group("NotificationsPage Widget Tests", () {
    late FakeNotificationRepository notificationRepo;
    late FakeSettingsRepository settingsRepo;

    setUp(() {
      notificationRepo = FakeNotificationRepository();
      settingsRepo = FakeSettingsRepository();
    });

    testWidgets("renders notification settings page and controls", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<INotificationRepository>.value(value: notificationRepo),
            Provider<ISettingsRepository>.value(value: settingsRepo),
          ],
          child: const MaterialApp(home: NotificationsPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Notification Settings"), findsOneWidget);
      expect(find.text("Practice Timer Completion"), findsOneWidget);
      expect(find.text("Daily Practice Reminder"), findsOneWidget);

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
    });
  });
}
