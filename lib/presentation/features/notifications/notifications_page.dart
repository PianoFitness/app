import "package:flutter/material.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_constants.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page_view_model.dart";
import "package:piano_fitness/presentation/features/notifications/widgets/notification_permission_dialog.dart";
import "package:piano_fitness/presentation/widgets/main_navigation_scope.dart";
import "package:provider/provider.dart";

/// A calm, standard settings list for notification preferences.
class NotificationsPage extends StatelessWidget {
  /// Creates the notifications page.
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = NotificationsPageViewModel(
          notificationRepository: context.read<INotificationRepository>(),
          settingsRepository: context.read<ISettingsRepository>(),
        );
        viewModel.initialize();
        return viewModel;
      },
      child: Consumer<NotificationsPageViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          appBar: MainNavigationScope.isActive(context)
              ? null
              : AppBar(title: const Text("Notification Settings")),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _NotificationSettingsList(viewModel: viewModel),
        ),
      ),
    );
  }
}

class _NotificationSettingsList extends StatelessWidget {
  const _NotificationSettingsList({required this.viewModel});

  final NotificationsPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final settings = viewModel.settings;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            children: [
              ListTile(
                key: const Key("notification_permission_setting"),
                leading: Icon(
                  settings.permissionGranted
                      ? Icons.check_circle_outline
                      : Icons.notifications_off_outlined,
                ),
                title: const Text("Notification permission"),
                subtitle: Text(
                  settings.permissionGranted
                      ? "Allowed"
                      : "Needed for reminders and timer alerts",
                ),
                trailing: settings.permissionGranted
                    ? null
                    : TextButton(
                        onPressed: () => _requestPermissions(context),
                        child: const Text("Enable"),
                      ),
              ),
              const Divider(indent: Spacing.md, endIndent: Spacing.md),
              SwitchListTile(
                key: const Key("timer_completion_setting"),
                secondary: const Icon(Icons.timer_outlined),
                title: const Text("Timer completion"),
                subtitle: const Text("Notify me when a practice timer ends"),
                value: settings.timerCompletionEnabled,
                onChanged: settings.permissionGranted
                    ? (value) => _setTimerCompletion(context, value)
                    : null,
              ),
              SwitchListTile(
                key: const Key("practice_reminder_setting"),
                secondary: const Icon(Icons.calendar_today_outlined),
                title: const Text("Daily practice reminder"),
                subtitle: const Text("A gentle prompt to keep your routine"),
                value: settings.practiceRemindersEnabled,
                onChanged: settings.permissionGranted
                    ? (value) => _setPracticeReminder(context, value)
                    : null,
              ),
              if (settings.practiceRemindersEnabled &&
                  settings.dailyReminderTime != null)
                ListTile(
                  key: const Key("practice_reminder_time_setting"),
                  contentPadding: const EdgeInsets.only(
                    left: 72,
                    right: Spacing.md,
                  ),
                  title: const Text("Reminder time"),
                  subtitle: Text(settings.dailyReminderTime!.format(context)),
                  trailing: TextButton(
                    onPressed: () => _changeReminderTime(context),
                    child: const Text("Change"),
                  ),
                ),
              if (!settings.permissionGranted)
                Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Text(
                    "Enable notification permission first, then choose which reminders you want.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setTimerCompletion(BuildContext context, bool value) async {
    if (!value) {
      await viewModel.setTimerCompletionEnabled(false);
      return;
    }
    if (await _ensurePermission(context)) {
      await viewModel.setTimerCompletionEnabled(true);
    }
  }

  Future<void> _setPracticeReminder(BuildContext context, bool value) async {
    if (!value) {
      await viewModel.setPracticeRemindersEnabled(false);
      return;
    }
    if (!await _ensurePermission(context) || !context.mounted) return;
    final time = await _showTimePicker(context);
    if (time != null) {
      await viewModel.setPracticeRemindersEnabled(true, reminderTime: time);
    }
  }

  Future<void> _changeReminderTime(BuildContext context) async {
    final time = await _showTimePicker(
      context,
      currentTime: viewModel.settings.dailyReminderTime,
    );
    if (time != null) await viewModel.updateDailyReminderTime(time);
  }

  Future<bool> _ensurePermission(BuildContext context) async {
    if (viewModel.settings.permissionGranted) return true;
    return _requestPermissions(context);
  }

  Future<bool> _requestPermissions(BuildContext context) async {
    final granted = await viewModel.requestPermissions();
    if (!granted && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => const NotificationPermissionDialog(),
      );
    }
    return granted;
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context, {
    TimeOfDay? currentTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: currentTime ?? NotificationsUIConstants.defaultReminderTime,
      helpText: "Select practice reminder time",
    );
  }
}
