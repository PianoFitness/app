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
class ProfileInitializer extends StatefulWidget {
  /// Creates a profile initializer.
  const ProfileInitializer({super.key});

  @override
  State<ProfileInitializer> createState() => _ProfileInitializerState();
}

class _ProfileInitializerState extends State<ProfileInitializer> {
  bool _isLoading = true;
  bool _showProfileChooser = false;

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
        // No profiles: show chooser with create prompt
        setState(() {
          _showProfileChooser = true;
          _isLoading = false;
        });
      } else if (profiles.length == 1) {
        // Single profile: auto-select and go to main app
        await repository.setActiveProfileId(profiles.first.id);
        setState(() {
          _showProfileChooser = false;
          _isLoading = false;
        });
      } else {
        // Multiple profiles: check active profile ID
        final activeId = await repository.getActiveProfileId();
        final hasValidActive =
            activeId != null && profiles.any((p) => p.id == activeId);

        setState(() {
          _showProfileChooser = !hasValidActive;
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, show profile chooser to let user recover
      setState(() {
        _showProfileChooser = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showProfileChooser) {
      return const UserProfilePage();
    }

    return const MainNavigation();
  }
}
