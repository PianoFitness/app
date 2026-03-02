import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../../../domain/models/user_profile.dart";

/// List item widget for displaying a user profile.
///
/// Shows the profile name, last practice date, and action buttons for edit/delete.
class ProfileListItem extends StatelessWidget {
  /// Creates a profile list item.
  const ProfileListItem({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// The profile to display.
  final UserProfile profile;

  /// Callback when the profile is tapped (primary action - select profile).
  final VoidCallback onTap;

  /// Callback when the edit button is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete button is tapped.
  final VoidCallback onDelete;

  String _formatLastPractice(DateTime? lastPractice) {
    if (lastPractice == null) {
      return "Never practiced";
    }

    final now = DateTime.now();
    // Create date-only versions for accurate day comparison
    final nowDate = DateTime(now.year, now.month, now.day);
    final lastPracticeDate = DateTime(
      lastPractice.year,
      lastPractice.month,
      lastPractice.day,
    );

    // Compare calendar dates instead of duration
    if (nowDate == lastPracticeDate) {
      return "Last practiced today";
    }

    final yesterday = nowDate.subtract(const Duration(days: 1));
    if (yesterday == lastPracticeDate) {
      return "Last practiced yesterday";
    }

    final daysDifference = nowDate.difference(lastPracticeDate).inDays;
    if (daysDifference == 0) {
      return "Last practiced today";
    } else if (daysDifference == 1) {
      return "Last practiced 1 day ago";
    } else if (daysDifference < 7) {
      return "Last practiced $daysDifference days ago";
    } else {
      return "Last practiced ${DateFormat.yMMMd().format(lastPractice)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        key: Key("profile_list_item_${profile.id}"),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastPractice(profile.lastPracticeDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: "Edit ${profile.displayName}",
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: "Delete ${profile.displayName}",
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
