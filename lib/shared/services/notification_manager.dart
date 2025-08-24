import "dart:convert";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/models/notification_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Manager for persisting notification settings and metadata.
///
/// This service handles storage of notification preferences and scheduled
/// notification metadata to maintain consistency across app sessions.
/// It works in conjunction with NotificationService to provide reliable
/// notification management.
class NotificationManager {
  NotificationManager._internal();
  static final NotificationManager _instance = NotificationManager._internal();
  static NotificationManager get instance => _instance;

  static final _log = Logger("NotificationManager");

  /// SharedPreferences keys for different data types.
  static const String _settingsKey = "notification_settings";
  static const String _scheduledNotificationsKey = "scheduled_notifications";

  /// Loads notification settings from persistent storage.
  ///
  /// Returns default settings if no saved settings exist.
  static Future<NotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        _log.info("No saved notification settings found, using defaults");
        return const NotificationSettings();
      }

      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = NotificationSettings(
        practiceRemindersEnabled:
            settingsMap["practiceRemindersEnabled"] as bool? ?? false,
        dailyReminderTime: settingsMap["dailyReminderTime"] != null
            ? _timeFromJson(
                settingsMap["dailyReminderTime"] as Map<String, dynamic>,
              )
            : null,
        timerCompletionEnabled:
            settingsMap["timerCompletionEnabled"] as bool? ?? false,
        permissionGranted: settingsMap["permissionGranted"] as bool? ?? false,
      );

      _log.info("Loaded notification settings: $settings");
      return settings;
    } catch (e) {
      _log.warning("Failed to load notification settings: $e");
      return const NotificationSettings();
    }
  }

  /// Saves notification settings to persistent storage.
  static Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsMap = {
        "practiceRemindersEnabled": settings.practiceRemindersEnabled,
        "dailyReminderTime": settings.dailyReminderTime != null
            ? _timeToJson(settings.dailyReminderTime!)
            : null,
        "timerCompletionEnabled": settings.timerCompletionEnabled,
        "permissionGranted": settings.permissionGranted,
      };

      await prefs.setString(_settingsKey, jsonEncode(settingsMap));
      _log.info("Saved notification settings: $settings");
    } catch (e) {
      _log.severe("Failed to save notification settings: $e");
      rethrow;
    }
  }

  /// Stores metadata about a scheduled notification.
  ///
  /// This allows us to track what notifications we've scheduled even if
  /// the plugin's internal state becomes inconsistent.
  static Future<void> saveScheduledNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime, {
    bool isRecurring = false,
    String? payload,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledNotifications = await _loadScheduledNotifications();

      scheduledNotifications[id.toString()] = {
        "id": id,
        "title": title,
        "body": body,
        "scheduledTime": scheduledTime.toIso8601String(),
        "isRecurring": isRecurring,
        "payload": payload,
        "createdAt": DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        _scheduledNotificationsKey,
        jsonEncode(scheduledNotifications),
      );

      _log.info(
        "Saved scheduled notification metadata: ID $id at $scheduledTime",
      );
    } catch (e) {
      _log.warning("Failed to save scheduled notification metadata: $e");
    }
  }

  /// Removes metadata about a scheduled notification.
  static Future<void> removeScheduledNotification(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledNotifications = await _loadScheduledNotifications();

      scheduledNotifications.remove(id.toString());

      await prefs.setString(
        _scheduledNotificationsKey,
        jsonEncode(scheduledNotifications),
      );

      _log.info("Removed scheduled notification metadata: ID $id");
    } catch (e) {
      _log.warning("Failed to remove scheduled notification metadata: $e");
    }
  }

  /// Gets metadata about all scheduled notifications.
  ///
  /// This can be used to reconcile with the plugin's pending notifications
  /// and detect inconsistencies.
  static Future<Map<String, dynamic>> getScheduledNotifications() async {
    return _loadScheduledNotifications();
  }

  /// Clears all scheduled notification metadata.
  ///
  /// Useful when resetting notification state or during development.
  static Future<void> clearAllScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduledNotificationsKey);
      _log.info("Cleared all scheduled notification metadata");
    } catch (e) {
      _log.warning("Failed to clear scheduled notification metadata: $e");
    }
  }

  /// Loads scheduled notifications from storage.
  static Future<Map<String, dynamic>> _loadScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = prefs.getString(_scheduledNotificationsKey);

      if (scheduledJson == null) return {};

      return jsonDecode(scheduledJson) as Map<String, dynamic>;
    } catch (e) {
      _log.warning("Failed to load scheduled notifications: $e");
      return {};
    }
  }

  /// Converts TimeOfDay to JSON-serializable format.
  static Map<String, dynamic> _timeToJson(TimeOfDay time) {
    return {"hour": time.hour, "minute": time.minute};
  }

  /// Converts JSON format back to TimeOfDay.
  static TimeOfDay _timeFromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json["hour"] as int, minute: json["minute"] as int);
  }

  /// Clears all stored notification data.
  ///
  /// This is primarily useful for testing or reset functionality.
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      await prefs.remove(_scheduledNotificationsKey);
      _log.info("Cleared all notification data");
    } catch (e) {
      _log.warning("Failed to clear notification data: $e");
    }
  }
}
