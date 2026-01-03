import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/features/notifications/notifications_constants.dart";
import "package:piano_fitness/features/notifications/notifications_page_view_model.dart";
import "package:piano_fitness/features/notifications/widgets/notification_permission_dialog.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:piano_fitness/shared/theme/semantic_colors.dart";

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
            ? (isLandscape ? Spacing.lg : Spacing.md)
            : (isLandscape ? Spacing.md : Spacing.sm);

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
      padding: EdgeInsets.all(
        NotificationsUIConstants.sectionPadding(isTablet),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
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
                    ? context.semanticColors.success
                    : colorScheme.outline,
                size: NotificationsUIConstants.sectionIconSize(isTablet),
              ),
              const SizedBox(width: Spacing.sm),
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
          const SizedBox(height: NotificationsUIConstants.sectionSmallSpacing),
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
      padding: EdgeInsets.all(
        NotificationsUIConstants.sectionPadding(isTablet),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: NotificationsUIConstants.shadowOffset,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: colorScheme.tertiary,
                size: NotificationsUIConstants.sectionIconSize(isTablet),
              ),
              const SizedBox(width: Spacing.sm),
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
          const SizedBox(height: NotificationsUIConstants.sectionSmallSpacing),
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
      padding: EdgeInsets.all(
        NotificationsUIConstants.sectionPadding(isTablet),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: NotificationsUIConstants.shadowOffset,
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
                color: colorScheme.secondary,
                size: NotificationsUIConstants.sectionIconSize(isTablet),
              ),
              const SizedBox(width: Spacing.sm),
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
          const SizedBox(height: NotificationsUIConstants.sectionSmallSpacing),
          if (settings.practiceRemindersEnabled &&
              settings.dailyReminderTime != null) ...[
            Row(
              children: [
                const SizedBox(width: Spacing.xl),
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
            const SizedBox(
              height: NotificationsUIConstants.sectionSmallSpacing,
            ),
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
      padding: EdgeInsets.all(
        NotificationsUIConstants.sectionPadding(isTablet),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.semanticColors.warning.withValues(alpha: 0.1),
            colorScheme.tertiaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: context.semanticColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_active,
            color: context.semanticColors.warning,
            size: NotificationsUIConstants.permissionPromptIconSize(isTablet),
          ),
          const SizedBox(height: NotificationsUIConstants.sectionInnerSpacing),
          Text(
            "Enable Notifications",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NotificationsUIConstants.sectionSmallSpacing),
          Text(
            "To use notification features, please grant permission when prompted.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: NotificationsUIConstants.permissionPromptSpacing,
          ),
          ElevatedButton(
            onPressed: () => _requestPermissions(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.semanticColors.warning,
              foregroundColor: colorScheme.onTertiary,
              padding: NotificationsUIConstants.buttonPadding(isTablet),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
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
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notification permission is required for this feature"),
          duration: NotificationsUIConstants.snackbarDuration,
        ),
      );
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
    return showTimePicker(
      context: context,
      initialTime: NotificationsUIConstants.defaultReminderTime,
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
