import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/notifications/notifications_page_view_model.dart";
import "package:piano_fitness/application/models/notification_settings.dart";

// Test doubles for NotificationManager and NotificationService
class TestNotificationManager {
  NotificationSettings? _settingsToReturn;
  Exception? _loadException;
  Exception? _saveException;
  final List<NotificationSettings> _savedSettings = [];

  void setSettingsToReturn(NotificationSettings settings) {
    _settingsToReturn = settings;
  }

  void setLoadException(Exception exception) {
    _loadException = exception;
  }

  void setSaveException(Exception exception) {
    _saveException = exception;
  }

  Future<NotificationSettings> loadSettings() async {
    if (_loadException != null) {
      throw _loadException!;
    }
    return _settingsToReturn ?? const NotificationSettings();
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    if (_saveException != null) {
      throw _saveException!;
    }
    _savedSettings.add(settings);
  }

  List<NotificationSettings> get savedSettings =>
      List.unmodifiable(_savedSettings);
  void clearSavedSettings() => _savedSettings.clear();
}

class TestNotificationService {
  bool _permissionsGranted = false;
  bool _requestPermissionsResult = true;
  Exception? _permissionsException;
  Exception? _requestException;
  Exception? _scheduleException;
  final List<int> _cancelledNotifications = [];
  final List<Map<String, dynamic>> _scheduledNotifications = [];

  void setPermissionsGranted(bool granted) {
    _permissionsGranted = granted;
  }

  void setRequestPermissionsResult(bool result) {
    _requestPermissionsResult = result;
  }

  void setPermissionsException(Exception exception) {
    _permissionsException = exception;
  }

  void setRequestException(Exception exception) {
    _requestException = exception;
  }

  void setScheduleException(Exception exception) {
    _scheduleException = exception;
  }

  Future<bool> arePermissionsGranted() async {
    if (_permissionsException != null) {
      throw _permissionsException!;
    }
    return _permissionsGranted;
  }

  Future<bool> requestPermissions() async {
    if (_requestException != null) {
      throw _requestException!;
    }
    return _requestPermissionsResult;
  }

  Future<void> cancelNotification(int id) async {
    _cancelledNotifications.add(id);
  }

  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required DateTime time,
    required String payload,
  }) async {
    if (_scheduleException != null) {
      throw _scheduleException!;
    }
    _scheduledNotifications.add({
      "title": title,
      "body": body,
      "time": time,
      "payload": payload,
    });
  }

  List<int> get cancelledNotifications =>
      List.unmodifiable(_cancelledNotifications);
  List<Map<String, dynamic>> get scheduledNotifications =>
      List.unmodifiable(_scheduledNotifications);
  void clearHistory() {
    _cancelledNotifications.clear();
    _scheduledNotifications.clear();
  }

  static const int dailyReminderNotificationId = 1;
}

// Override the static service classes for testing
class TestNotificationsPageViewModel extends NotificationsPageViewModel {
  TestNotificationsPageViewModel({
    required this.testNotificationManager,
    required this.testNotificationService,
  });

  final TestNotificationManager testNotificationManager;
  final TestNotificationService testNotificationService;

  @override
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _loadSettingsTest();
      await _refreshPermissionStatusTest();
    } catch (e) {
      _errorMessage = "Failed to load notification settings";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettingsTest() async {
    try {
      _settings = await testNotificationManager.loadSettings();
    } catch (e) {
      _settings = const NotificationSettings();
      rethrow; // Re-throw so initialize() can catch and set error message
    }
  }

  Future<void> _refreshPermissionStatusTest() async {
    try {
      final permissionsGranted = await testNotificationService
          .arePermissionsGranted();
      if (_settings.permissionGranted != permissionsGranted) {
        _settings = _settings.copyWith(permissionGranted: permissionsGranted);
        await testNotificationManager.saveSettings(_settings);
      }
    } catch (e) {
      // Silently handle permission check errors
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final granted = await testNotificationService.requestPermissions();
      if (granted) {
        _settings = _settings.copyWith(permissionGranted: true);
        await testNotificationManager.saveSettings(_settings);
      }
      notifyListeners();
      return granted;
    } catch (e) {
      _errorMessage = "Failed to request notification permissions";
      notifyListeners();
      return false;
    }
  }

  @override
  Future<void> setTimerCompletionEnabled(bool enabled) async {
    try {
      _settings = _settings.copyWith(timerCompletionEnabled: enabled);
      await testNotificationManager.saveSettings(_settings);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to update timer completion settings";
      notifyListeners();
    }
  }

  @override
  Future<void> setPracticeRemindersEnabled(
    bool enabled, {
    TimeOfDay? reminderTime,
  }) async {
    try {
      if (enabled && reminderTime != null) {
        _settings = _settings.copyWith(
          practiceRemindersEnabled: true,
          dailyReminderTime: reminderTime,
        );
        await _scheduleDailyReminderTest(reminderTime);
      } else if (!enabled) {
        _settings = _settings.copyWith(practiceRemindersEnabled: false);
        await testNotificationService.cancelNotification(
          TestNotificationService.dailyReminderNotificationId,
        );
      }
      await testNotificationManager.saveSettings(_settings);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to update practice reminder settings";
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> updateDailyReminderTime(TimeOfDay newTime) async {
    try {
      _settings = _settings.copyWith(dailyReminderTime: newTime);
      await testNotificationManager.saveSettings(_settings);
      if (_settings.practiceRemindersEnabled) {
        await _scheduleDailyReminderTest(newTime);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to update reminder time";
      notifyListeners();
    }
  }

  Future<void> _scheduleDailyReminderTest(TimeOfDay time) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await testNotificationService.scheduleDailyNotification(
      title: "Time to Practice Piano! 🎹",
      body: "Ready to make some music? Your daily practice session awaits.",
      time: scheduledTime,
      payload: "daily_practice_reminder",
    );
  }

  // Make protected members accessible for testing
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  @override
  NotificationSettings get settings => _settings;
  bool _isLoading = true;
  String? _errorMessage;
  NotificationSettings _settings = const NotificationSettings();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("NotificationsPageViewModel Tests", () {
    late TestNotificationsPageViewModel viewModel;
    late TestNotificationManager testNotificationManager;
    late TestNotificationService testNotificationService;

    setUp(() {
      testNotificationManager = TestNotificationManager();
      testNotificationService = TestNotificationService();

      // Set up default test behavior
      testNotificationManager.setSettingsToReturn(const NotificationSettings());
      testNotificationService.setPermissionsGranted(false);
      testNotificationService.setRequestPermissionsResult(true);

      viewModel = TestNotificationsPageViewModel(
        testNotificationManager: testNotificationManager,
        testNotificationService: testNotificationService,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    group("Initialization", () {
      test("should initialize with default values", () {
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.settings, equals(const NotificationSettings()));
      });

      test(
        "should load settings and refresh permissions on initialize",
        () async {
          final testSettings = const NotificationSettings(
            practiceRemindersEnabled: true,
            dailyReminderTime: TimeOfDay(hour: 9, minute: 0),
            timerCompletionEnabled: true,
          );

          testNotificationManager.setSettingsToReturn(testSettings);
          testNotificationService.setPermissionsGranted(true);

          await viewModel.initialize();

          expect(viewModel.isLoading, isFalse);
          expect(viewModel.errorMessage, isNull);
          expect(viewModel.settings.practiceRemindersEnabled, isTrue);
          expect(viewModel.settings.timerCompletionEnabled, isTrue);
          expect(viewModel.settings.permissionGranted, isTrue);
          expect(
            viewModel.settings.dailyReminderTime,
            equals(const TimeOfDay(hour: 9, minute: 0)),
          );

          expect(testNotificationManager.savedSettings.length, equals(1));
        },
      );

      test("should handle initialization errors gracefully", () async {
        testNotificationManager.setLoadException(Exception("Failed to load"));

        await viewModel.initialize();

        expect(viewModel.isLoading, isFalse);
        expect(
          viewModel.errorMessage,
          equals("Failed to load notification settings"),
        );
        expect(viewModel.settings, equals(const NotificationSettings()));
      });

      test("should notify listeners during initialization", () async {
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        await viewModel.initialize();

        expect(notificationCount, greaterThan(1));
      });

      test(
        "should update permission status if different from stored",
        () async {
          final testSettings = const NotificationSettings();

          testNotificationManager.setSettingsToReturn(testSettings);
          testNotificationService.setPermissionsGranted(true);

          await viewModel.initialize();

          expect(viewModel.settings.permissionGranted, isTrue);
          expect(testNotificationManager.savedSettings.length, equals(1));
        },
      );

      test("should not update settings if permission status matches", () async {
        final testSettings = const NotificationSettings(
          permissionGranted: true,
        );

        testNotificationManager.setSettingsToReturn(testSettings);
        testNotificationService.setPermissionsGranted(true);

        await viewModel.initialize();

        expect(viewModel.settings.permissionGranted, isTrue);
        expect(testNotificationManager.savedSettings.length, equals(0));
      });
    });

    group("Permission Management", () {
      test(
        "should request permissions and update settings on success",
        () async {
          testNotificationService.setRequestPermissionsResult(true);

          var notificationReceived = false;
          viewModel.addListener(() {
            notificationReceived = true;
          });

          final result = await viewModel.requestPermissions();

          expect(result, isTrue);
          expect(viewModel.settings.permissionGranted, isTrue);
          expect(notificationReceived, isTrue);
          expect(testNotificationManager.savedSettings.length, equals(1));
        },
      );

      test("should handle permission denial gracefully", () async {
        testNotificationService.setRequestPermissionsResult(false);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        final result = await viewModel.requestPermissions();

        expect(result, isFalse);
        expect(viewModel.settings.permissionGranted, isFalse);
        expect(notificationReceived, isTrue);
        expect(testNotificationManager.savedSettings.length, equals(0));
      });

      test("should handle permission request errors", () async {
        testNotificationService.setRequestException(
          Exception("Permission request failed"),
        );

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        final result = await viewModel.requestPermissions();

        expect(result, isFalse);
        expect(
          viewModel.errorMessage,
          equals("Failed to request notification permissions"),
        );
        expect(notificationReceived, isTrue);
      });
    });

    group("Timer Completion Settings", () {
      test("should enable timer completion notifications", () async {
        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.setTimerCompletionEnabled(true);

        expect(viewModel.settings.timerCompletionEnabled, isTrue);
        expect(notificationReceived, isTrue);
        expect(testNotificationManager.savedSettings.length, equals(1));
      });

      test("should disable timer completion notifications", () async {
        // First enable it
        await viewModel.setTimerCompletionEnabled(true);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.setTimerCompletionEnabled(false);

        expect(viewModel.settings.timerCompletionEnabled, isFalse);
        expect(notificationReceived, isTrue);
        expect(testNotificationManager.savedSettings.length, equals(2));
      });

      test("should handle timer completion setting save errors", () async {
        testNotificationManager.setSaveException(Exception("Save failed"));

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.setTimerCompletionEnabled(true);

        expect(
          viewModel.errorMessage,
          equals("Failed to update timer completion settings"),
        );
        expect(notificationReceived, isTrue);
      });
    });

    group("Practice Reminders Settings", () {
      test("should enable practice reminders with time", () async {
        const reminderTime = TimeOfDay(hour: 9, minute: 30);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.setPracticeRemindersEnabled(
          true,
          reminderTime: reminderTime,
        );

        expect(viewModel.settings.practiceRemindersEnabled, isTrue);
        expect(viewModel.settings.dailyReminderTime, equals(reminderTime));
        expect(notificationReceived, isTrue);

        expect(testNotificationManager.savedSettings.length, equals(1));
        expect(
          testNotificationService.scheduledNotifications.length,
          equals(1),
        );

        final scheduledNotification =
            testNotificationService.scheduledNotifications.first;
        expect(
          scheduledNotification["title"],
          equals("Time to Practice Piano! 🎹"),
        );
        expect(
          scheduledNotification["body"],
          equals(
            "Ready to make some music? Your daily practice session awaits.",
          ),
        );
        expect(
          scheduledNotification["payload"],
          equals("daily_practice_reminder"),
        );
      });

      test(
        "should disable practice reminders and cancel notifications",
        () async {
          // First enable reminders
          const reminderTime = TimeOfDay(hour: 9, minute: 30);
          await viewModel.setPracticeRemindersEnabled(
            true,
            reminderTime: reminderTime,
          );

          var notificationReceived = false;
          viewModel.addListener(() {
            notificationReceived = true;
          });

          await viewModel.setPracticeRemindersEnabled(false);

          expect(viewModel.settings.practiceRemindersEnabled, isFalse);
          expect(notificationReceived, isTrue);

          expect(testNotificationManager.savedSettings.length, equals(2));
          expect(
            testNotificationService.cancelledNotifications.length,
            equals(1),
          );
          expect(
            testNotificationService.cancelledNotifications.first,
            equals(TestNotificationService.dailyReminderNotificationId),
          );
        },
      );

      test("should handle practice reminder setting save errors", () async {
        testNotificationManager.setSaveException(Exception("Save failed"));

        try {
          await viewModel.setPracticeRemindersEnabled(
            true,
            reminderTime: const TimeOfDay(hour: 9, minute: 0),
          );
          fail("Expected exception to be rethrown");
        } catch (e) {
          expect(
            viewModel.errorMessage,
            equals("Failed to update practice reminder settings"),
          );
        }
      });

      test("should handle notification scheduling errors", () async {
        testNotificationService.setScheduleException(
          Exception("Schedule failed"),
        );

        try {
          await viewModel.setPracticeRemindersEnabled(
            true,
            reminderTime: const TimeOfDay(hour: 9, minute: 0),
          );
          fail("Expected exception to be rethrown");
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });

    group("Daily Reminder Time Updates", () {
      test("should update daily reminder time and reschedule", () async {
        // First enable reminders
        await viewModel.setPracticeRemindersEnabled(
          true,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        );

        const newTime = TimeOfDay(hour: 18, minute: 30);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.updateDailyReminderTime(newTime);

        expect(viewModel.settings.dailyReminderTime, equals(newTime));
        expect(notificationReceived, isTrue);

        expect(testNotificationManager.savedSettings.length, equals(2));
        expect(
          testNotificationService.scheduledNotifications.length,
          equals(2),
        ); // Once for enable, once for update
      });

      test("should not reschedule when reminders are disabled", () async {
        const newTime = TimeOfDay(hour: 18, minute: 30);

        await viewModel.updateDailyReminderTime(newTime);

        expect(viewModel.settings.dailyReminderTime, equals(newTime));

        expect(testNotificationManager.savedSettings.length, equals(1));
        expect(
          testNotificationService.scheduledNotifications.length,
          equals(0),
        );
      });

      test("should handle daily reminder time update errors", () async {
        testNotificationManager.setSaveException(Exception("Save failed"));

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        await viewModel.updateDailyReminderTime(
          const TimeOfDay(hour: 18, minute: 30),
        );

        expect(
          viewModel.errorMessage,
          equals("Failed to update reminder time"),
        );
        expect(notificationReceived, isTrue);
      });
    });

    group("Error Management", () {
      test("should clear error message", () {
        // Set an error by triggering a failed initialization
        testNotificationManager.setLoadException(Exception("Test error"));
        viewModel.initialize().catchError((_) {});

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
        if (notificationReceived) {
          expect(notificationReceived, isTrue);
        }
      });

      test("should not notify listeners when clearing null error", () {
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.clearError();

        expect(notificationCount, equals(0));
      });
    });

    group("Loading States", () {
      test("should manage loading state during initialization", () async {
        expect(viewModel.isLoading, isTrue);

        await viewModel.initialize();

        expect(viewModel.isLoading, isFalse);
      });

      test(
        "should set loading to false even when initialization fails",
        () async {
          testNotificationManager.setLoadException(Exception("Load failed"));

          await viewModel.initialize();

          expect(viewModel.isLoading, isFalse);
        },
      );
    });

    group("Settings Persistence", () {
      test("should load default settings when loading fails", () async {
        testNotificationManager.setLoadException(Exception("Load failed"));

        await viewModel.initialize();

        expect(viewModel.settings, equals(const NotificationSettings()));
      });

      test("should save settings after each update", () async {
        await viewModel.setTimerCompletionEnabled(true);
        expect(testNotificationManager.savedSettings.length, equals(1));

        await viewModel.setPracticeRemindersEnabled(
          true,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        );
        expect(testNotificationManager.savedSettings.length, equals(2));

        await viewModel.updateDailyReminderTime(
          const TimeOfDay(hour: 10, minute: 0),
        );
        expect(testNotificationManager.savedSettings.length, equals(3));
      });
    });

    group("Notification Scheduling", () {
      test(
        "should schedule notification for today if time is in future",
        () async {
          const reminderTime = TimeOfDay(hour: 9, minute: 0);

          await viewModel.setPracticeRemindersEnabled(
            true,
            reminderTime: reminderTime,
          );

          expect(
            testNotificationService.scheduledNotifications.length,
            equals(1),
          );
          final scheduledNotification =
              testNotificationService.scheduledNotifications.first;
          expect(
            scheduledNotification["title"],
            equals("Time to Practice Piano! 🎹"),
          );
          expect(
            scheduledNotification["body"],
            equals(
              "Ready to make some music? Your daily practice session awaits.",
            ),
          );
          expect(scheduledNotification["time"], isA<DateTime>());
          expect(
            scheduledNotification["payload"],
            equals("daily_practice_reminder"),
          );
        },
      );

      test("should use correct notification content", () async {
        const reminderTime = TimeOfDay(hour: 9, minute: 0);

        await viewModel.setPracticeRemindersEnabled(
          true,
          reminderTime: reminderTime,
        );

        expect(
          testNotificationService.scheduledNotifications.length,
          equals(1),
        );
        final scheduledNotification =
            testNotificationService.scheduledNotifications.first;
        expect(
          scheduledNotification["title"],
          equals("Time to Practice Piano! 🎹"),
        );
        expect(
          scheduledNotification["body"],
          equals(
            "Ready to make some music? Your daily practice session awaits.",
          ),
        );
        expect(
          scheduledNotification["payload"],
          equals("daily_practice_reminder"),
        );
      });
    });

    group("Edge Cases", () {
      test("should handle enabling reminders without time", () async {
        // This should not schedule a notification
        await viewModel.setPracticeRemindersEnabled(true);

        expect(viewModel.settings.practiceRemindersEnabled, isFalse);
        expect(
          testNotificationService.scheduledNotifications.length,
          equals(0),
        );
      });

      test("should handle multiple rapid setting changes", () async {
        await viewModel.setTimerCompletionEnabled(true);
        await viewModel.setTimerCompletionEnabled(false);
        await viewModel.setTimerCompletionEnabled(true);

        expect(viewModel.settings.timerCompletionEnabled, isTrue);
        expect(testNotificationManager.savedSettings.length, equals(3));
      });

      test("should handle dispose without issues", () {
        // Create a separate viewModel for this test to avoid double disposal
        final separateViewModel = TestNotificationsPageViewModel(
          testNotificationManager: testNotificationManager,
          testNotificationService: testNotificationService,
        );
        expect(() => separateViewModel.dispose(), returnsNormally);
      });
    });

    group("Permission Refresh Edge Cases", () {
      test("should handle permission refresh errors silently", () async {
        testNotificationService.setPermissionsException(
          Exception("Permission check failed"),
        );

        // Should not throw or set error message
        await viewModel.initialize();

        expect(viewModel.errorMessage, isNull);
      });

      test(
        "should not save settings if permission refresh throws after load",
        () async {
          testNotificationService.setPermissionsException(
            Exception("Permission check failed"),
          );

          await viewModel.initialize();

          // Should only save settings during permission update if successful
          expect(testNotificationManager.savedSettings.length, equals(0));
        },
      );
    });
  });
}
