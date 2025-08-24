import "package:flutter/foundation.dart";
import "package:piano_fitness/shared/models/notification_settings.dart";

/// ViewModel for managing notifications page state and business logic.
///
/// This class will be fully implemented in Phase 2 with complete
/// notification settings management and permission handling.
class NotificationsPageViewModel extends ChangeNotifier {
  NotificationsPageViewModel() {
    _settings = const NotificationSettings();
  }

  late NotificationSettings _settings;

  /// Current notification settings.
  NotificationSettings get settings => _settings;

  /// Placeholder method for updating settings.
  /// Will be implemented in Phase 2.
  void updateSettings(NotificationSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // Dispose method will be implemented in Phase 2
}
