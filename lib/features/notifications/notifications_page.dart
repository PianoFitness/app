import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/features/notifications/notifications_page_view_model.dart";
import "package:piano_fitness/features/notifications/widgets/notification_permission_dialog.dart";

/// Notifications configuration page for managing user notification preferences.
///
/// This page allows users to configure practice reminders, timer completion
/// notifications, and manage notification permissions. It follows the app's
/// design guidelines with responsive layouts and comprehensive accessibility.
class NotificationsPage extends StatefulWidget {
  /// Creates the notifications page.
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsPageViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationsPageViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Notification Settings"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Consumer<NotificationsPageViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildNotificationSettings(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    NotificationsPageViewModel viewModel,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout based on design guidelines
        final isTablet = constraints.maxWidth >= 768;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final padding = isTablet
            ? (isLandscape ? 24.0 : 20.0)
            : (isLandscape ? 16.0 : 12.0);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPermissionSection(context, viewModel, isTablet),
              SizedBox(height: padding),
              _buildTimerCompletionSection(context, viewModel, isTablet),
              SizedBox(height: padding),
              _buildDailyReminderSection(context, viewModel, isTablet),
              if (!viewModel.settings.permissionGranted) ...[
                SizedBox(height: padding * 1.5),
                _buildPermissionPrompt(context, viewModel, isTablet),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionSection(
    BuildContext context,
    NotificationsPageViewModel viewModel,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = viewModel.settings;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.05),
            Colors.purple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settings.permissionGranted
                    ? Icons.check_circle
                    : Icons.notifications_off,
                color: settings.permissionGranted
                    ? Colors.green
                    : colorScheme.outline,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Notification Permission",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            settings.permissionGranted
                ? "Notifications are enabled and ready to use."
                : "Grant permission to receive practice reminders and timer notifications.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCompletionSection(
    BuildContext context,
    NotificationsPageViewModel viewModel,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = viewModel.settings;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.orange, size: isTablet ? 24 : 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Practice Timer Completion",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Semantics(
                label: settings.timerCompletionEnabled
                    ? "Timer completion notifications enabled"
                    : "Timer completion notifications disabled",
                button: true,
                child: Switch(
                  value: settings.timerCompletionEnabled,
                  onChanged: settings.permissionGranted
                      ? (value) async {
                          if (!value) {
                            await viewModel.setTimerCompletionEnabled(false);
                          } else {
                            await _handlePermissionAndToggle(
                              context,
                              viewModel,
                              () => viewModel.setTimerCompletionEnabled(true),
                            );
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Get notified when your practice timer completes, even when the app is in the background.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReminderSection(
    BuildContext context,
    NotificationsPageViewModel viewModel,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = viewModel.settings;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.blue,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Daily Practice Reminder",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Semantics(
                label: settings.practiceRemindersEnabled
                    ? "Daily practice reminders enabled"
                    : "Daily practice reminders disabled",
                button: true,
                child: Switch(
                  value: settings.practiceRemindersEnabled,
                  onChanged: settings.permissionGranted
                      ? (value) async {
                          if (!value) {
                            await viewModel.setPracticeRemindersEnabled(false);
                          } else {
                            await _handlePermissionAndToggle(
                              context,
                              viewModel,
                              () async {
                                // Show time picker
                                final time = await _showTimePicker(context);
                                if (time != null) {
                                  await viewModel.setPracticeRemindersEnabled(
                                    true,
                                    reminderTime: time,
                                  );
                                }
                              },
                            );
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (settings.practiceRemindersEnabled &&
              settings.dailyReminderTime != null) ...[
            Row(
              children: [
                const SizedBox(width: 32),
                Text(
                  "Reminder time: ${settings.dailyReminderTime!.format(context)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final time = await _showTimePicker(context);
                    if (time != null) {
                      await viewModel.updateDailyReminderTime(time);
                    }
                  },
                  child: const Text("Change"),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            "Receive a daily notification at your chosen time to remind you to practice piano.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPrompt(
    BuildContext context,
    NotificationsPageViewModel viewModel,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.amber.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_active,
            color: Colors.orange,
            size: isTablet ? 32 : 28,
          ),
          const SizedBox(height: 12),
          Text(
            "Enable Notifications",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "To use notification features, please grant permission when prompted.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _requestPermissions(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Grant Permission"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionAndToggle(
    BuildContext context,
    NotificationsPageViewModel viewModel,
    VoidCallback onPermissionGranted,
  ) async {
    if (viewModel.settings.permissionGranted) {
      onPermissionGranted();
      return;
    }

    final granted = await _requestPermissions(context, viewModel);
    if (granted) {
      onPermissionGranted();
    }
  }

  Future<bool> _requestPermissions(
    BuildContext context,
    NotificationsPageViewModel viewModel,
  ) async {
    final granted = await viewModel.requestPermissions();

    if (!granted && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => const NotificationPermissionDialog(),
      );
    }

    return granted;
  }

  Future<TimeOfDay?> _showTimePicker(BuildContext context) async {
    const defaultTime = TimeOfDay(hour: 18, minute: 0); // 6:00 PM default

    return showTimePicker(
      context: context,
      initialTime: defaultTime,
      helpText: "Select practice reminder time",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.primary,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialTextColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
