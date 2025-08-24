import "dart:io";
import "package:flutter/foundation.dart";
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
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  static final _log = Logger("NotificationService");
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Sync stored notification data with plugin state
      await _syncStoredWithPending();

      _isInitialized = true;
      _log.info("Notification service initialized successfully");
    } catch (e) {
      _log.severe("Failed to initialize notification service: $e");
      rethrow;
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
      throw StateError("NotificationService must be initialized first");
    }

    try {
      if (kIsWeb) {
        _log.info("Web platform detected - permissions handled by browser");
        return true;
      }

      if (Platform.isIOS || Platform.isMacOS) {
        _log.info("Requesting iOS/macOS notification permissions");
        final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        _log.info("Permission request result: $granted");
        return granted ?? false;
      }

      // Other platforms (Android, etc.) - assume granted
      return true;
    } catch (e) {
      _log.warning("Failed to request permissions: $e");
      return false;
    }
  }

  /// Checks if notification permissions are currently granted.
  static Future<bool> arePermissionsGranted() async {
    if (!_isInitialized) return false;

    try {
      if (kIsWeb) {
        return true; // Web permissions are handled differently
      }

      if (Platform.isIOS || Platform.isMacOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        final bool? enabled = await iosImplementation?.checkPermissions().then(
          (settings) => settings?.isEnabled,
        );

        return enabled ?? false;
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
  }) async {
    if (!_isInitialized) {
      throw StateError("NotificationService must be initialized first");
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
        timerCompletionNotificationId,
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
      throw StateError("NotificationService must be initialized first");
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
      throw StateError("NotificationService must be initialized first");
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
      final pendingRequests = await _plugin.pendingNotificationRequests();
      final pendingIds = pendingRequests
          .map((req) => req.id.toString())
          .toSet();

      _log.info(
        "Found ${storedNotifications.length} stored notifications, ${pendingRequests.length} pending",
      );

      // Find notifications that are stored but not actually pending
      final staleNotifications = <String>[];

      for (final entry in storedNotifications.entries) {
        final storedId = entry.key;
        final storedData = entry.value as Map<String, dynamic>;

        if (!pendingIds.contains(storedId)) {
          // Check if this notification is in the past
          final scheduledTime = DateTime.parse(
            storedData["scheduledTime"] as String,
          );

          if (scheduledTime.isBefore(DateTime.now()) &&
              !(storedData["isRecurring"] as bool? ?? false)) {
            // Non-recurring notification that already fired - remove from storage
            staleNotifications.add(storedId);
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
}
