import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/user_profile_repository_impl.dart";
import "package:piano_fitness/domain/models/profile_sort_order.dart";
import "package:piano_fitness/features/user_profile/user_profile_page.dart";
import "package:piano_fitness/features/user_profile/widgets/profile_list_item.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../shared/test_helpers/widget_test_helper.dart";

/// Integration tests for user profile management workflows.
///
/// These tests verify end-to-end functionality using a real repository
/// implementation with an in-memory database, ensuring all layers work
/// together correctly.
void main() {
  group("User Profile Integration Tests", () {
    late AppDatabase database;
    late UserProfileRepositoryImpl repository;

    setUp(() async {
      // Use in-memory database for isolated test execution
      database = AppDatabase(NativeDatabase.memory());

      // Use fake SharedPreferences for active profile ID persistence
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      repository = UserProfileRepositoryImpl(database: database, prefs: prefs);
    });

    tearDown(() async {
      await database.close();
    });

    group("Profile Creation Workflow", () {
      testWidgets("should create profile and display it in list", (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state initially
        expect(find.text("No Profiles Yet"), findsOneWidget);

        // Tap FAB to open create dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Enter profile name
        await tester.enterText(find.byType(TextField), "Alice");
        await tester.pumpAndSettle();

        // Tap create button
        await tester.tap(find.byKey(const Key("profile_create_submit_button")));
        await tester.pumpAndSettle();

        // Wait for navigation away (profile creation and auto-selection)
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Dialog should have closed and we navigated away from the page
        // Since we're testing in isolation, verify the repository state
        final profiles = await repository.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles[0].displayName, equals("Alice"));

        final activeId = await repository.getActiveProfileId();
        expect(activeId, equals(profiles[0].id));
      });

      testWidgets("should create multiple profiles", (tester) async {
        // Pre-create first profile so we stay on the page
        await repository.createProfile("Alice");

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Should show first profile
        expect(find.text("Alice"), findsOneWidget);

        // Create second profile
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), "Bob");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("profile_create_submit_button")));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify both profiles exist in repository
        final profiles = await repository.getAllProfiles();
        expect(profiles, hasLength(2));
        expect(
          profiles.map((p) => p.displayName),
          containsAll(["Alice", "Bob"]),
        );
      });
    });

    group("Profile Editing Workflow", () {
      testWidgets("should edit profile and update display", (tester) async {
        // Create initial profile
        await repository.createProfile("Alice");

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text("Alice"), findsOneWidget);

        // Tap edit button
        final editButton = find.descendant(
          of: find.byType(ProfileListItem),
          matching: find.byIcon(Icons.edit),
        );
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Update name
        await tester.enterText(find.byType(TextField), "Alice Smith");
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.byKey(const Key("profile_edit_save_button")));
        await tester.pumpAndSettle();

        // Verify updated name is displayed
        expect(find.text("Alice Smith"), findsOneWidget);
        expect(find.text("Alice"), findsNothing);

        // Verify repository state
        final profiles = await repository.getAllProfiles();
        expect(profiles[0].displayName, equals("Alice Smith"));
      });
    });

    group("Profile Deletion Workflow", () {
      testWidgets("should delete profile and remove from list", (tester) async {
        // Create profiles
        await repository.createProfile("Alice");
        await repository.createProfile("Bob");

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ProfileListItem), findsNWidgets(2));

        // Find Alice's delete button
        final aliceItem = find.ancestor(
          of: find.text("Alice"),
          matching: find.byType(ProfileListItem),
        );
        final deleteButton = find.descendant(
          of: aliceItem,
          matching: find.byIcon(Icons.delete),
        );

        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Confirm deletion
        await tester.tap(
          find.byKey(const Key("profile_delete_confirm_button")),
        );
        await tester.pumpAndSettle();

        // Verify only Bob remains
        expect(find.text("Alice"), findsNothing);
        expect(find.text("Bob"), findsOneWidget);
        expect(find.byType(ProfileListItem), findsOneWidget);

        final profiles = await repository.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles[0].displayName, equals("Bob"));
      });

      testWidgets("should handle deleting active profile", (tester) async {
        // Create profiles
        final alice = await repository.createProfile("Alice");
        await repository.createProfile("Bob");
        await repository.setActiveProfileId(alice.id);

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Delete active profile (Alice)
        final aliceItem = find.ancestor(
          of: find.text("Alice"),
          matching: find.byType(ProfileListItem),
        );
        final deleteButton = find.descendant(
          of: aliceItem,
          matching: find.byIcon(Icons.delete),
        );

        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key("profile_delete_confirm_button")),
        );
        await tester.pumpAndSettle();

        // Verify Bob remains
        final profiles = await repository.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles[0].displayName, equals("Bob"));

        // Active profile should be auto-selected to Bob
        final activeId = await repository.getActiveProfileId();
        expect(activeId, equals(profiles[0].id));
      });

      testWidgets("should cancel deletion", (tester) async {
        await repository.createProfile("Alice");

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Attempt to delete
        final deleteButton = find.descendant(
          of: find.byType(ProfileListItem),
          matching: find.byIcon(Icons.delete),
        );

        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Cancel
        await tester.tap(find.byKey(const Key("profile_delete_cancel_button")));
        await tester.pumpAndSettle();

        // Verify profile still exists
        expect(find.text("Alice"), findsOneWidget);
        final profiles = await repository.getAllProfiles();
        expect(profiles, hasLength(1));
      });
    });

    group("Profile Selection Workflow", () {
      testWidgets("should select profile and set as active", (tester) async {
        final alice = await repository.createProfile("Alice");
        await repository.createProfile("Bob");

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Tap Alice's profile card using list item key
        await tester.tap(find.byKey(Key("profile_list_item_${alice.id}")));
        await tester.pumpAndSettle();

        // Verify Alice is now active
        final activeId = await repository.getActiveProfileId();
        expect(activeId, equals(alice.id));
      });
    });

    group("Sort Order Workflow", () {
      testWidgets("should toggle sort order and persist preference", (
        tester,
      ) async {
        // Create profiles with different names and practice dates
        await repository.createProfile("Zebra");
        final bob = await repository.createProfile("Bob");
        await repository.createProfile("Alice");

        // Update Bob's practice date to make it most recent
        await repository.updateProfile(
          bob.copyWith(lastPracticeDate: DateTime.now()),
        );

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Default sort should be last active (most recent first)
        final firstSort = await repository.getSortOrder();
        expect(firstSort, equals(ProfileSortOrder.lastActive));

        // Toggle to alphabetical
        await tester.tap(find.byIcon(Icons.access_time));
        await tester.pumpAndSettle();

        // Verify sort order changed
        final secondSort = await repository.getSortOrder();
        expect(secondSort, equals(ProfileSortOrder.alphabetical));

        // Restart widget to verify persistence
        await tester.pumpWidget(Container());
        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Sort order should still be alphabetical
        final persistedSort = await repository.getSortOrder();
        expect(persistedSort, equals(ProfileSortOrder.alphabetical));
      });
    });

    group("Error Handling", () {
      testWidgets("should handle repository errors gracefully", (tester) async {
        // Close database to simulate error condition
        await database.close();

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // When database is closed, Drift operations may complete but with stale/empty data
        // The app should still function and show empty or error state without crashing
        expect(find.byType(UserProfilePage), findsOneWidget);
        // Verify UI is shown (either error state with retry button or empty state)
        // The closed database might show empty state instead of error
        final hasRetryButton = find.byKey(
          const Key("profile_error_retry_button"),
        );
        final hasEmptyState = find.text("No Profiles Yet");
        // At least one of these should be present
        final retryExists = tester.any(hasRetryButton);
        final emptyExists = tester.any(hasEmptyState);
        expect(
          retryExists || emptyExists,
          isTrue,
          reason: "Should show either error state with retry or empty state",
        );
      });
    });
  });
}
