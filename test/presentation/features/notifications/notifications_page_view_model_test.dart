import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/notification_settings_data.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page_view_model.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  late MockINotificationRepository mockNotificationRepository;
  late MockISettingsRepository mockSettingsRepository;
  late NotificationsPageViewModel viewModel;

  setUp(() {
    mockNotificationRepository = MockINotificationRepository();
    mockSettingsRepository = MockISettingsRepository();

    // Default mock behavior
    when(
      mockSettingsRepository.loadNotificationSettings(),
    ).thenAnswer((_) async => const NotificationSettingsData());
    when(
      mockSettingsRepository.saveNotificationSettings(any),
    ).thenAnswer((_) async {});
    when(
      mockNotificationRepository.arePermissionsGranted(),
    ).thenAnswer((_) async => false);
    when(
      mockNotificationRepository.requestPermissions(),
    ).thenAnswer((_) async => true);
    when(
      mockNotificationRepository.dailyReminderNotificationId,
    ).thenReturn(100);
    when(
      mockNotificationRepository.cancelNotification(any),
    ).thenAnswer((_) async {});
    when(
      mockNotificationRepository.scheduleDailyNotification(
        title: anyNamed("title"),
        body: anyNamed("body"),
        scheduledTime: anyNamed("scheduledTime"),
      ),
    ).thenAnswer((_) async {});

    viewModel = NotificationsPageViewModel(
      notificationRepository: mockNotificationRepository,
      settingsRepository: mockSettingsRepository,
    );
  });

  group("NotificationsPageViewModel Tests", () {
    test("initialize loads settings and refreshes permissions", () async {
      when(mockSettingsRepository.loadNotificationSettings()).thenAnswer(
        (_) async => const NotificationSettingsData(
          practiceRemindersEnabled: true,
          permissionGranted: true,
        ),
      );
      when(
        mockNotificationRepository.arePermissionsGranted(),
      ).thenAnswer((_) async => true);

      await viewModel.initialize();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.settings.practiceRemindersEnabled, isTrue);
      expect(viewModel.settings.permissionGranted, isTrue);
    });

    test("requestPermissions updates permission state on success", () async {
      when(
        mockNotificationRepository.requestPermissions(),
      ).thenAnswer((_) async => true);

      final granted = await viewModel.requestPermissions();

      expect(granted, isTrue);
      expect(viewModel.settings.permissionGranted, isTrue);
      verify(mockSettingsRepository.saveNotificationSettings(any)).called(1);
    });

    test("setTimerCompletionEnabled updates setting and persists", () async {
      await viewModel.setTimerCompletionEnabled(true);

      expect(viewModel.settings.timerCompletionEnabled, isTrue);
      verify(mockSettingsRepository.saveNotificationSettings(any)).called(1);
    });

    test("setPracticeRemindersEnabled true schedules notification", () async {
      const reminderTime = TimeOfDay(hour: 9, minute: 30);

      await viewModel.setPracticeRemindersEnabled(
        true,
        reminderTime: reminderTime,
      );

      expect(viewModel.settings.practiceRemindersEnabled, isTrue);
      // Verify the scheduling called with exact title/body
      verify(
        mockNotificationRepository.scheduleDailyNotification(
          title: "Time to Practice Piano! 🎹",
          body: "Ready to make some music? Your daily practice session awaits.",
          scheduledTime: captureAnyNamed('scheduledTime'),
        ),
      ).called(1);
      // Capture the scheduled time and assert hour/minute are 9:30
      final capturedTime = verify(
        mockNotificationRepository.scheduleDailyNotification(
          title: anyNamed('title'),
          body: anyNamed('body'),
          scheduledTime: captureAnyNamed('scheduledTime'),
        ),
      ).captured.first as DateTime;
      expect(capturedTime.hour, equals(9));
      expect(capturedTime.minute, equals(30));
    });

    test("setPracticeRemindersEnabled false cancels notification", () async {
      await viewModel.setPracticeRemindersEnabled(false);

      expect(viewModel.settings.practiceRemindersEnabled, isFalse);
      verify(mockNotificationRepository.cancelNotification(100)).called(1);
    });

    test(
      "updateDailyReminderTime reschedules notification if enabled",
      () async {
        when(mockSettingsRepository.loadNotificationSettings()).thenAnswer(
          (_) async => const NotificationSettingsData(
            practiceRemindersEnabled: true,
            dailyReminderHour: 8,
            dailyReminderMinute: 0,
          ),
        );
        await viewModel.initialize();

        const newTime = TimeOfDay(hour: 10, minute: 15);
        await viewModel.updateDailyReminderTime(newTime);

        verify(
          mockNotificationRepository.scheduleDailyNotification(
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledTime: captureAnyNamed('scheduledTime'),
          ),
        ).called(1);
        final capturedNewTime = verify(
          mockNotificationRepository.scheduleDailyNotification(
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledTime: captureAnyNamed('scheduledTime'),
          ),
        ).captured.first as DateTime;
        expect(capturedNewTime.hour, equals(10));
        expect(capturedNewTime.minute, equals(15));
      },
    );

    test("clearError resets error message", () async {
      when(
        mockNotificationRepository.requestPermissions(),
      ).thenThrow(Exception("Permission check failed"));

      await viewModel.requestPermissions();
      expect(viewModel.errorMessage, isNotNull);

      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
    });
  });
}
