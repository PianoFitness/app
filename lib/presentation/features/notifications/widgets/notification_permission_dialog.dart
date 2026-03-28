import "package:flutter/material.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_constants.dart";

/// Dialog displayed when notification permissions are denied.
///
/// This dialog provides guidance to users on how to enable notifications
/// manually in their system settings. It follows the app's design guidelines
/// with proper accessibility support.
class NotificationPermissionDialog extends StatelessWidget {
  /// Creates a notification permission dialog.
  const NotificationPermissionDialog({super.key});

  /// Key for the "I Understand" button used in tests.
  static const kUnderstandButtonKey = Key(
    "notification_permission_dialog_understand_button",
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Icon(
            Icons.notifications_off,
            color: colorScheme.tertiary,
            size: ComponentDimensions.iconSizeLarge,
            semanticLabel: "Notifications are disabled",
          ),
          const SizedBox(width: NotificationsUIConstants.sectionInnerSpacing),
          Expanded(
            child: Text(
              "Notifications Disabled",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications were not enabled. To use notification features:",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(
                NotificationsUIConstants.sectionInnerSpacing,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStep(context, "1.", "Open your device Settings"),
                  const SizedBox(height: Spacing.sm),
                  _buildStep(
                    context,
                    "2.",
                    "Find Piano Fitness in the app list",
                  ),
                  const SizedBox(height: Spacing.sm),
                  _buildStep(context, "3.", "Enable Notifications"),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              "You can always change notification settings later in the Piano Fitness app.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: kUnderstandButtonKey,
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text("I Understand"),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String number, String description) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ComponentDimensions.iconSizeMedium,
          height: ComponentDimensions.iconSizeMedium,
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(
              ComponentDimensions.iconSizeMedium / 2,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(width: NotificationsUIConstants.sectionInnerSpacing),
        Expanded(
          child: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
