import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../domain/repositories/user_profile_repository.dart";
import "../../features/user_profile/user_profile_page.dart";
import "../widgets/main_navigation.dart";

/// Widget that handles profile initialization on app startup.
///
/// Determines whether to show the profile chooser or main app based on:
/// - Number of profiles (0, 1, or 2+)
/// - Active profile ID validity
///
/// On first launch with 0 profiles, pushes to UserProfilePage and waits.
/// When user returns (after creating profile), re-checks and navigates to MainNavigation.
class ProfileInitializer extends StatefulWidget {
  /// Creates a profile initializer.
  const ProfileInitializer({super.key});

  @override
  State<ProfileInitializer> createState() => _ProfileInitializerState();
}

class _ProfileInitializerState extends State<ProfileInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeProfileState();
  }

  Future<void> _initializeProfileState() async {
    final repository = context.read<IUserProfileRepository>();

    try {
      final profiles = await repository.getAllProfiles();

      if (profiles.isEmpty) {
        // No profiles: navigate to chooser with create prompt
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const UserProfilePage(),
            ),
          );
          // When returning from profile page, re-check
          if (mounted) {
            _initializeProfileState();
          }
        }
      } else if (profiles.length == 1) {
        // Single profile: auto-select and go to main app
        await repository.setActiveProfileId(profiles.first.id);
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const MainNavigation(),
            ),
          );
        }
      } else {
        // Multiple profiles: check active profile ID
        final activeId = await repository.getActiveProfileId();
        final hasValidActive =
            activeId != null && profiles.any((p) => p.id == activeId);

        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => hasValidActive
                  ? const MainNavigation()
                  : const UserProfilePage(),
            ),
          );
        }
      }
    } catch (e) {
      // On error, show profile chooser to let user recover
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const UserProfilePage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
