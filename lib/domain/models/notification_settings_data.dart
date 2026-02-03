/// Domain model representing user notification preferences and settings.
///
/// This is a framework-independent model using only core Dart types,
/// allowing the domain layer to remain decoupled from UI frameworks.
class NotificationSettingsData {
  /// Creates a new NotificationSettingsData instance.
  const NotificationSettingsData({
    this.practiceRemindersEnabled = false,
    this.dailyReminderHour,
    this.dailyReminderMinute,
    this.timerCompletionEnabled = false,
    this.permissionGranted = false,
  });

  /// Whether daily practice reminder notifications are enabled.
  final bool practiceRemindersEnabled;

  /// The hour (0-23) for daily practice reminders.
  /// Null if practice reminders are disabled.
  final int? dailyReminderHour;

  /// The minute (0-59) for daily practice reminders.
  /// Null if practice reminders are disabled.
  final int? dailyReminderMinute;

  /// Whether timer completion notifications are enabled.
  final bool timerCompletionEnabled;

  /// Whether notification permissions have been granted by the user.
  final bool permissionGranted;

  /// Whether any notifications are enabled.
  bool get hasAnyNotificationsEnabled =>
      practiceRemindersEnabled || timerCompletionEnabled;

  /// Whether daily reminder time is set.
  bool get hasDailyReminderTime =>
      dailyReminderHour != null && dailyReminderMinute != null;

  /// Creates a copy of this settings with the given fields replaced.
  NotificationSettingsData copyWith({
    bool? practiceRemindersEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? timerCompletionEnabled,
    bool? permissionGranted,
  }) {
    return NotificationSettingsData(
      practiceRemindersEnabled:
          practiceRemindersEnabled ?? this.practiceRemindersEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      timerCompletionEnabled:
          timerCompletionEnabled ?? this.timerCompletionEnabled,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }

  /// Creates a NotificationSettingsData instance with daily reminder time cleared.
  NotificationSettingsData clearDailyReminderTime() {
    return NotificationSettingsData(
      practiceRemindersEnabled: practiceRemindersEnabled,
      timerCompletionEnabled: timerCompletionEnabled,
      permissionGranted: permissionGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsData &&
          runtimeType == other.runtimeType &&
          practiceRemindersEnabled == other.practiceRemindersEnabled &&
          dailyReminderHour == other.dailyReminderHour &&
          dailyReminderMinute == other.dailyReminderMinute &&
          timerCompletionEnabled == other.timerCompletionEnabled &&
          permissionGranted == other.permissionGranted;

  @override
  int get hashCode =>
      practiceRemindersEnabled.hashCode ^
      (dailyReminderHour?.hashCode ?? 0) ^
      (dailyReminderMinute?.hashCode ?? 0) ^
      timerCompletionEnabled.hashCode ^
      permissionGranted.hashCode;

  @override
  String toString() {
    return "NotificationSettingsData("
        "practiceRemindersEnabled: $practiceRemindersEnabled, "
        "dailyReminderHour: $dailyReminderHour, "
        "dailyReminderMinute: $dailyReminderMinute, "
        "timerCompletionEnabled: $timerCompletionEnabled, "
        "permissionGranted: $permissionGranted)";
  }
}
