import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/models/notification_settings.dart";
import "package:piano_fitness/shared/services/notification_manager.dart";
import "package:piano_fitness/shared/services/notification_service.dart";

/// ViewModel for managing notifications page state and business logic.
///
/// This class handles all notification-related operations including
/// loading/saving settings, managing permissions, and scheduling notifications.
/// It follows the MVVM pattern and provides reactive updates to the UI.
class NotificationsPageViewModel extends ChangeNotifier {
  NotificationsPageViewModel();

  static final _log = Logger("NotificationsPageViewModel");

  NotificationSettings _settings = const NotificationSettings();
  bool _isLoading = true;
  String? _errorMessage;

  /// Current notification settings.
  NotificationSettings get settings => _settings;

  /// Whether the ViewModel is currently loading data.
  bool get isLoading => _isLoading;

  /// Current error message, if any.
  String? get errorMessage => _errorMessage;

  /// Initializes the ViewModel by loading settings and checking permissions.
  Future<void> initialize() async {
    _log.info("Initializing notifications page view model");

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load saved settings
      await _loadSettings();

      // Check current permission status and update if needed
      await _refreshPermissionStatus();

      _log.info("Notifications page view model initialized successfully");
    } catch (e) {
      _log.severe("Failed to initialize notifications page view model: $e");
      _errorMessage = "Failed to load notification settings";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Requests notification permissions from the system.
  ///
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> requestPermissions() async {
    _log.info("Requesting notification permissions");

    try {
      final granted = await NotificationService.requestPermissions();

      if (granted) {
        _settings = _settings.copyWith(permissionGranted: true);
        await _saveSettings();
        _log.info("Notification permissions granted");
      } else {
        _log.warning("Notification permissions denied");
      }

      notifyListeners();
      return granted;
    } catch (e) {
      _log.severe("Failed to request permissions: $e");
      _errorMessage = "Failed to request notification permissions";
      notifyListeners();
      return false;
    }
  }

  /// Enables or disables timer completion notifications.
  Future<void> setTimerCompletionEnabled(bool enabled) async {
    _log.info("Setting timer completion notifications: $enabled");

    try {
      _settings = _settings.copyWith(timerCompletionEnabled: enabled);
      await _saveSettings();

      _log.info(
        "Timer completion notifications ${enabled ? 'enabled' : 'disabled'}",
      );
      notifyListeners();
    } catch (e) {
      _log.severe("Failed to set timer completion enabled: $e");
      _errorMessage = "Failed to update timer completion settings";
      notifyListeners();
    }
  }

  /// Enables or disables daily practice reminders.
  ///
  /// If [reminderTime] is provided when enabling, schedules the daily notification.
  Future<void> setPracticeRemindersEnabled(
    bool enabled, {
    TimeOfDay? reminderTime,
  }) async {
    _log.info("Setting practice reminders: $enabled, time: $reminderTime");

    try {
      if (enabled && reminderTime != null) {
        // Enable reminders with the specified time
        _settings = _settings.copyWith(
          practiceRemindersEnabled: true,
          dailyReminderTime: reminderTime,
        );

        // Schedule the daily notification
        await _scheduleDailyReminder(reminderTime);
      } else if (!enabled) {
        // Disable reminders and cancel scheduled notifications
        _settings = _settings.copyWith(practiceRemindersEnabled: false);

        // Cancel existing daily reminders
        await NotificationService.cancelNotification(
          NotificationService.dailyReminderNotificationId,
        );
      }

      await _saveSettings();

      _log.info("Practice reminders ${enabled ? 'enabled' : 'disabled'}");
      notifyListeners();
    } catch (e) {
      _log.severe("Failed to set practice reminders enabled: $e");
      _errorMessage = "Failed to update practice reminder settings";
      notifyListeners();
    }
  }

  /// Updates the time for daily practice reminders.
  ///
  /// Reschedules the notification with the new time.
  Future<void> updateDailyReminderTime(TimeOfDay newTime) async {
    _log.info("Updating daily reminder time: $newTime");

    try {
      _settings = _settings.copyWith(dailyReminderTime: newTime);
      await _saveSettings();

      // Reschedule the daily reminder
      if (_settings.practiceRemindersEnabled) {
        await _scheduleDailyReminder(newTime);
      }

      _log.info("Daily reminder time updated to: $newTime");
      notifyListeners();
    } catch (e) {
      _log.severe("Failed to update daily reminder time: $e");
      _errorMessage = "Failed to update reminder time";
      notifyListeners();
    }
  }

  /// Clears any current error message.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Loads notification settings from persistent storage.
  Future<void> _loadSettings() async {
    try {
      _settings = await NotificationManager.loadSettings();
      _log.fine("Loaded notification settings: $_settings");
    } catch (e) {
      _log.warning("Failed to load settings: $e");
      _settings = const NotificationSettings();
    }
  }

  /// Saves current settings to persistent storage.
  Future<void> _saveSettings() async {
    try {
      await NotificationManager.saveSettings(_settings);
      _log.fine("Saved notification settings: $_settings");
    } catch (e) {
      _log.warning("Failed to save settings: $e");
      rethrow;
    }
  }

  /// Refreshes the permission status from the system.
  Future<void> _refreshPermissionStatus() async {
    try {
      final permissionsGranted =
          await NotificationService.arePermissionsGranted();

      if (_settings.permissionGranted != permissionsGranted) {
        _settings = _settings.copyWith(permissionGranted: permissionsGranted);
        await _saveSettings();
        _log.info("Updated permission status: $permissionsGranted");
      }
    } catch (e) {
      _log.warning("Failed to refresh permission status: $e");
    }
  }

  /// Schedules a daily practice reminder notification.
  Future<void> _scheduleDailyReminder(TimeOfDay time) async {
    try {
      // Create a DateTime for today at the specified time
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the scheduled time is before now, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await NotificationService.scheduleDailyNotification(
        title: "Time to Practice Piano! 🎹",
        body: "Ready to make some music? Your daily practice session awaits.",
        time: scheduledTime,
        payload: "daily_practice_reminder",
      );

      _log.info(
        "Scheduled daily reminder for ${scheduledTime.toIso8601String()}",
      );
    } catch (e) {
      _log.severe("Failed to schedule daily reminder: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _log.fine("Disposing notifications page view model");
    super.dispose();
  }
}
