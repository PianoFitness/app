import "dart:io";
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/services/notification_manager.dart";
import "package:timezone/timezone.dart" as tz;

/// Service for managing local notifications across platforms.
///
/// This service provides a centralized interface for showing immediate
/// notifications, scheduling future notifications, and managing permissions
/// on supported platforms (macOS, iOS, limited web support).
class NotificationService {
  NotificationService._internal();

  static final _log = Logger("NotificationService");
  static dynamic _plugin = FlutterLocalNotificationsPlugin();

  /// Sets a custom plugin instance (for testing only)
  static void setPluginForTesting(dynamic plugin) {
    _plugin = plugin;
    _isInitialized = false;
  }

  static bool _isInitialized = false;

  /// Notification channel IDs for different notification types.
  static const String _instantChannelId = "instant_notifications";
  static const String _scheduledChannelId = "scheduled_notifications";
  static const String _dailyReminderChannelId = "daily_reminders";

  /// Notification IDs for managing specific notifications.
  static const int dailyReminderNotificationId = 1001;
  static const int timerCompletionNotificationId = 1002;

  /// Initializes the notification service with platform-specific settings.
  ///
  /// Must be called before using other notification methods.
  /// Sets up notification channels, handlers, and syncs with stored data.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _log.info("Initializing notification service");

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        );

    try {
      _log.info("Initializing flutter_local_notifications plugin...");
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _log.info("Plugin initialized, syncing stored data...");

      // Sync stored notification data with plugin state
      await _syncStoredWithPending();

      _isInitialized = true;
      _log.info("Notification service initialized successfully");
    } catch (e, stackTrace) {
      _log.severe("Failed to initialize notification service: $e");
      _log.severe("Stack trace: $stackTrace");
      // Don't rethrow - allow the app to continue running
      // but mark as not initialized
      _isInitialized = false;
    }
  }

  /// Handles notification tap events.
  static void _onNotificationTapped(NotificationResponse response) {
    _log.fine("Notification tapped: ${response.payload}");
  }

  /// Requests notification permissions from the user.
  ///
  /// Returns true if permissions are granted, false otherwise.
  /// On platforms that don't require explicit permissions, returns true.
  static Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      _log.warning(
        "NotificationService not initialized, attempting to initialize now",
      );
      await initialize();
      if (!_isInitialized) {
        _log.severe(
          "NotificationService initialization failed, cannot request permissions",
        );
        return false;
      }
    }
    try {
      if (Platform.isIOS) {
        return await _requestIOSPermissions();
      } else if (Platform.isMacOS) {
        return await _requestMacOSPermissions();
      } else if (Platform.isAndroid) {
        return await _requestAndroidPermissions();
      }
      // Other platforms - assume granted
      return true;
    } catch (e) {
      _log.warning("Failed to request permissions: $e");
      return false;
    }
  }

  /// Checks if notification permissions are currently granted.
  static Future<bool> arePermissionsGranted() async {
    if (!_isInitialized) {
      _log.warning(
        "NotificationService not initialized, attempting to initialize now",
      );
      await initialize();
      if (!_isInitialized) {
        _log.warning(
          "NotificationService initialization failed, assuming permissions not granted",
        );
        return false;
      }
    }
    try {
      if (Platform.isIOS) {
        return await _checkIOSPermissions();
      } else if (Platform.isMacOS) {
        return await _checkMacOSPermissions();
      } else if (Platform.isAndroid) {
        return await _checkAndroidPermissions();
      }
      return true; // Assume granted on other platforms
    } catch (e) {
      _log.warning("Failed to check permissions: $e");
      return false;
    }
  }

  /// Shows an immediate notification.
  ///
  /// [title] and [body] are required. Optional [payload] can be used
  /// to pass data that will be available when the notification is tapped.
  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      _log.warning(
        "NotificationService not initialized, cannot show instant notification",
      );
      return;
    }

    try {
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          _instantChannelId,
          "Instant Notifications",
          channelDescription: "Immediate notifications for app events",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      );

      await _plugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      _log.info("Instant notification shown: $title");
    } catch (e) {
      _log.warning("Failed to show instant notification: $e");
    }
  }

  /// Schedules a notification for a specific date and time.
  ///
  /// [scheduledTime] must be in the future. The notification will be
  /// delivered at the specified time even if the app is not running.
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) {
      _log.warning(
        "NotificationService not initialized, cannot schedule notification",
      );
      return;
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      _log.warning("Cannot schedule notification in the past: $scheduledTime");
      return;
    }

    try {
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          _scheduledChannelId,
          "Scheduled Notifications",
          channelDescription: "Notifications scheduled for future delivery",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // Save metadata to persistent storage
      await NotificationManager.saveScheduledNotification(
        id,
        title,
        body,
        scheduledTime,
        payload: payload,
      );

      _log.info("Notification scheduled for $scheduledTime: $title");
    } catch (e) {
      _log.warning("Failed to schedule notification: $e");
    }
  }

  /// Schedules a daily recurring notification at the specified time.
  ///
  /// [time] specifies the daily time for the notification.
  /// The notification will repeat every day at this time.
  static Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required DateTime time,
    String? payload,
  }) async {
    if (!_isInitialized) {
      _log.warning(
        "NotificationService not initialized, cannot schedule daily notification",
      );
      return;
    }

    try {
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannelId,
          "Daily Practice Reminders",
          channelDescription: "Daily reminders for piano practice",
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      );

      final nextInstance = _nextInstanceOfTime(time);

      await _plugin.zonedSchedule(
        dailyReminderNotificationId,
        title,
        body,
        nextInstance,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      // Save metadata to persistent storage
      await NotificationManager.saveScheduledNotification(
        dailyReminderNotificationId,
        title,
        body,
        nextInstance.toLocal(),
        isRecurring: true,
        payload: payload,
      );

      _log.info(
        "Daily notification scheduled for ${time.hour}:${time.minute}: $title",
      );
    } catch (e) {
      _log.warning("Failed to schedule daily notification: $e");
    }
  }

  /// Cancels a specific scheduled notification by ID.
  static Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;

    try {
      await _plugin.cancel(id);

      // Remove from persistent storage
      await NotificationManager.removeScheduledNotification(id);

      _log.info("Cancelled notification with ID: $id");
    } catch (e) {
      _log.warning("Failed to cancel notification $id: $e");
    }
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _plugin.cancelAll();

      // Clear from persistent storage
      await NotificationManager.clearAllScheduledNotifications();

      _log.info("Cancelled all notifications");
    } catch (e) {
      _log.warning("Failed to cancel all notifications: $e");
    }
  }

  /// Calculates the next instance of the specified time.
  ///
  /// If the time has already passed today, returns tomorrow's instance.
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

  /// Syncs stored notification data with plugin's pending notifications.
  ///
  /// This method reconciles differences between what we think is scheduled
  /// and what the plugin actually has pending. It handles cases where:
  /// - Notifications were lost due to app updates/reinstalls
  /// - System cleared notifications due to device constraints
  /// - Plugin state became inconsistent
  static Future<void> _syncStoredWithPending() async {
    try {
      _log.info("Syncing stored notification data with plugin state");

      // Get our stored notification metadata
      final storedNotifications =
          await NotificationManager.getScheduledNotifications();

      // Get actually pending notifications from plugin
      final pendingRequests = await (_plugin as FlutterLocalNotificationsPlugin)
          .pendingNotificationRequests();
      final pendingIds = pendingRequests
          .map((PendingNotificationRequest req) => req.id)
          .toSet();

      _log.info(
        "Found ${storedNotifications.length} stored notifications, ${pendingRequests.length} pending",
      );

      // Find notifications that are stored but not actually pending
      final staleNotifications = <String>[];

      for (final entry in storedNotifications.entries) {
        final storedIdStr = entry.key;
        final storedData = entry.value as Map<String, dynamic>;
        final storedId = int.tryParse(storedIdStr);

        if (storedId == null || !pendingIds.contains(storedId)) {
          // Check if this notification is in the past
          DateTime? scheduledTime;
          try {
            scheduledTime = DateTime.parse(
              storedData["scheduledTime"] as String,
            );
          } catch (e) {
            _log.warning("Invalid scheduledTime for id=$storedIdStr: $e");
            staleNotifications.add(storedIdStr);
            continue;
          }

          final isRecurring = storedData["isRecurring"] as bool? ?? false;
          if (scheduledTime.isBefore(DateTime.now()) && !isRecurring) {
            // Non-recurring notification that already fired - remove from storage
            staleNotifications.add(storedIdStr);
            _log.info(
              "Removing completed notification from storage: $storedId",
            );
          } else {
            // Notification should still be scheduled but isn't - reschedule it
            _log.warning("Rescheduling missing notification: $storedId");
            await _rescheduleNotification(storedData);
          }
        }
      }

      // Clean up stale notifications
      for (final staleId in staleNotifications) {
        await NotificationManager.removeScheduledNotification(
          int.parse(staleId),
        );
      }

      _log.info(
        "Sync completed - removed ${staleNotifications.length} stale notifications",
      );
    } catch (e) {
      _log.warning("Error during notification sync: $e");
    }
  }

  /// Reschedules a notification from stored metadata.
  static Future<void> _rescheduleNotification(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final id = notificationData["id"] as int;
      final title = notificationData["title"] as String;
      final body = notificationData["body"] as String;
      final scheduledTime = DateTime.parse(
        notificationData["scheduledTime"] as String,
      );
      final isRecurring = notificationData["isRecurring"] as bool? ?? false;
      final payload = notificationData["payload"] as String?;

      if (isRecurring) {
        // For daily reminders, reschedule for the next occurrence
        await scheduleDailyNotification(
          title: title,
          body: body,
          time: scheduledTime,
          payload: payload,
        );
      } else if (scheduledTime.isAfter(DateTime.now())) {
        // For future one-time notifications, reschedule as-is
        await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: payload,
        );
      }

      _log.info("Rescheduled notification: $id");
    } catch (e) {
      _log.warning("Failed to reschedule notification: $e");
    }
  }

  /// Handles iOS-specific notification permission requests.
  static Future<bool> _requestIOSPermissions() async {
    _log.info("Requesting iOS notification permissions");
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final bool? granted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    _log.info("iOS permission request result: $granted");
    return granted ?? false;
  }

  /// Handles macOS-specific notification permission requests.
  static Future<bool> _requestMacOSPermissions() async {
    _log.info("Requesting macOS notification permissions");
    final MacOSFlutterLocalNotificationsPlugin? macosImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    final bool? granted = await macosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    _log.info("macOS permission request result: $granted");
    return granted ?? false;
  }

  /// Handles Android-specific notification permission requests.
  static Future<bool> _requestAndroidPermissions() async {
    _log.info("Requesting Android notification permissions");
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Check Android SDK version
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    _log.info("Android SDK version: $sdkInt");

    if (sdkInt >= 33) {
      // Android 13+ requires POST_NOTIFICATIONS permission
      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      _log.info("Android permission request result: $granted");
      return granted ?? false;
    } else {
      // Pre-Android 13, no explicit permission needed
      _log.info("Android SDK < 33, assuming permissions granted");
      return true;
    }
  }

  /// Checks iOS-specific notification permissions.
  static Future<bool> _checkIOSPermissions() async {
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final bool? enabled = await iosImplementation?.checkPermissions().then(
      (settings) => settings?.isEnabled,
    );
    return enabled ?? false;
  }

  /// Checks macOS-specific notification permissions.
  static Future<bool> _checkMacOSPermissions() async {
    final MacOSFlutterLocalNotificationsPlugin? macosImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    final bool? enabled = await macosImplementation?.checkPermissions().then(
      (settings) => settings?.isEnabled,
    );
    return enabled ?? false;
  }

  /// Checks Android-specific notification permissions.
  static Future<bool> _checkAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        (_plugin as FlutterLocalNotificationsPlugin?)
            ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Check Android SDK version
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+ requires POST_NOTIFICATIONS permission
      final bool? granted = await androidImplementation
          ?.areNotificationsEnabled();
      return granted ?? false;
    } else {
      // Pre-Android 13, assume granted
      return true;
    }
  }

  /// Returns whether the service is initialized (for testing only).
  static bool get isInitialized => _isInitialized;
}
