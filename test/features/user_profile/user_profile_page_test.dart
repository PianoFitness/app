import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/profile_sort_order.dart";
import "package:piano_fitness/domain/models/user_profile.dart";
import "package:piano_fitness/features/user_profile/user_profile_page.dart";
import "package:piano_fitness/features/user_profile/widgets/profile_list_item.dart";

import "../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../shared/test_helpers/widget_test_helper.dart";

void main() {
  group("UserProfilePage", () {
    late MockIUserProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockIUserProfileRepository();
    });

    testWidgets("should display loading indicator initially", (tester) async {
      when(mockRepository.getAllProfiles()).thenAnswer(
        (_) async =>
            Future.delayed(const Duration(milliseconds: 100), () => []),
      );
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("should display empty state when no profiles exist", (
      tester,
    ) async {
      when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("No Profiles Yet"), findsOneWidget);
      expect(
        find.text(
          "Create your first profile to get started with Piano Fitness.",
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.text("Create Profile"), findsNWidgets(2)); // Button + FAB
    });

    testWidgets("should display error state on repository error", (
      tester,
    ) async {
      when(
        mockRepository.getAllProfiles(),
      ).thenThrow(Exception("Database error"));

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Error Loading Profiles"), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text("Retry"), findsOneWidget);
    });

    testWidgets("should retry loading profiles when retry button tapped", (
      tester,
    ) async {
      var callCount = 0;
      when(mockRepository.getAllProfiles()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception("First attempt failed");
        }
        return [];
      });
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Error Loading Profiles"), findsOneWidget);

      await tester.tap(find.byKey(const Key("profile_error_retry_button")));
      await tester.pumpAndSettle();

      // Should now show empty state instead of error
      expect(find.text("No Profiles Yet"), findsOneWidget);
      expect(find.text("Error Loading Profiles"), findsNothing);
      verify(mockRepository.getAllProfiles()).called(2);
    });

    testWidgets("should display profile list when profiles exist", (
      tester,
    ) async {
      final profiles = [
        UserProfile(id: "1", displayName: "Alice", createdAt: DateTime(2026)),
        UserProfile(
          id: "2",
          displayName: "Bob",
          createdAt: DateTime(2026, 1, 2),
        ),
        UserProfile(
          id: "3",
          displayName: "Charlie",
          createdAt: DateTime(2026, 1, 3),
        ),
      ];

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => profiles);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProfileListItem), findsNWidgets(3));
      expect(find.text("Alice"), findsOneWidget);
      expect(find.text("Bob"), findsOneWidget);
      expect(find.text("Charlie"), findsOneWidget);
    });

    testWidgets(
      "should show alphabetical sort icon when sort is alphabetical",
      (tester) async {
        when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
        when(
          mockRepository.getSortOrder(),
        ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
        when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: mockRepository,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.sort_by_alpha), findsOneWidget);
        expect(find.byIcon(Icons.access_time), findsNothing);

        final sortButton = find.byIcon(Icons.sort_by_alpha);
        final iconButton = tester.widget<IconButton>(
          find.ancestor(of: sortButton, matching: find.byType(IconButton)),
        );

        expect(iconButton.tooltip, equals("Sort by last active"));
      },
    );

    testWidgets("should show time sort icon when sort is by last active", (
      tester,
    ) async {
      when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.lastActive);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.sort_by_alpha), findsNothing);

      final sortButton = find.byIcon(Icons.access_time);
      final iconButton = tester.widget<IconButton>(
        find.ancestor(of: sortButton, matching: find.byType(IconButton)),
      );

      expect(iconButton.tooltip, equals("Sort alphabetically"));
    });

    testWidgets("should toggle sort order when sort button tapped", (
      tester,
    ) async {
      final profiles = [
        UserProfile(id: "1", displayName: "Zebra", createdAt: DateTime(2026)),
        UserProfile(
          id: "2",
          displayName: "Apple",
          createdAt: DateTime(2026, 1, 2),
        ),
      ];

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => profiles);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
      when(
        mockRepository.setSortOrder(ProfileSortOrder.lastActive),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort_by_alpha), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sort_by_alpha));
      await tester.pumpAndSettle();

      verify(
        mockRepository.setSortOrder(ProfileSortOrder.lastActive),
      ).called(1);
    });

    testWidgets("should navigate back when profile is selected", (
      tester,
    ) async {
      final profiles = [
        UserProfile(id: "1", displayName: "Alice", createdAt: DateTime(2026)),
      ];

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => profiles);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
      when(mockRepository.setActiveProfileId("1")).thenAnswer((_) async => {});

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProfileListItem), findsOneWidget);

      await tester.tap(find.byType(ProfileListItem));
      await tester.pumpAndSettle();

      verify(mockRepository.setActiveProfileId("1")).called(1);
      // Note: Navigator.pop() is difficult to verify in widget tests
      // without a more complex navigation setup
    });

    testWidgets("should show create profile dialog when FAB tapped", (
      tester,
    ) async {
      when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Create Profile"), findsAtLeastNWidgets(1));
    });

    testWidgets(
      "should create profile and navigate back on successful creation",
      (tester) async {
        final newProfile = UserProfile(
          id: "1",
          displayName: "New User",
          createdAt: DateTime(2026, 3, 2),
        );

        when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
        when(
          mockRepository.getSortOrder(),
        ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
        when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
        when(
          mockRepository.createProfile("New User"),
        ).thenAnswer((_) async => newProfile);
        when(
          mockRepository.setActiveProfileId("1"),
        ).thenAnswer((_) async => {});

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const UserProfilePage(),
            userProfileRepository: mockRepository,
          ),
        );

        await tester.pumpAndSettle();

        // Tap FAB to open create dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Enter profile name
        await tester.enterText(find.byType(TextField), "New User");
        await tester.pumpAndSettle();

        // Tap create button
        await tester.tap(find.byKey(const Key("profile_create_submit_button")));
        await tester.pumpAndSettle();

        verify(mockRepository.createProfile("New User")).called(1);
        verify(mockRepository.setActiveProfileId("1")).called(1);
      },
    );

    testWidgets("should show error snackbar when profile creation fails", (
      tester,
    ) async {
      when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
      when(
        mockRepository.createProfile(any),
      ).thenThrow(Exception("Creation failed"));

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Tap FAB to open create dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter profile name
      await tester.enterText(find.byType(TextField), "Test");
      await tester.pumpAndSettle();

      // Tap create button
      await tester.tap(find.byKey(const Key("profile_create_submit_button")));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining("Exception"),
        ),
        findsOneWidget,
      );
    });

    testWidgets("should show edit dialog when edit button tapped", (
      tester,
    ) async {
      final profile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => [profile]);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap edit button (first IconButton in the list item)
      final editButton = find.descendant(
        of: find.byType(ProfileListItem),
        matching: find.byIcon(Icons.edit),
      );

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Should show edit dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Edit Profile"), findsOneWidget);
    });

    testWidgets("should update profile when edit is saved", (tester) async {
      final profile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );
      final updatedProfile = profile.copyWith(displayName: "Alice Smith");

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => [profile]);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
      when(
        mockRepository.updateProfile(any),
      ).thenAnswer((_) async => updatedProfile);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Tap edit button
      final editButton = find.descendant(
        of: find.byType(ProfileListItem),
        matching: find.byIcon(Icons.edit),
      );

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Clear and enter new name
      await tester.enterText(find.byType(TextField), "Alice Smith");
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.byKey(const Key("profile_edit_save_button")));
      await tester.pumpAndSettle();

      verify(mockRepository.updateProfile(any)).called(1);
      expect(find.text("Profile updated"), findsOneWidget);
    });

    testWidgets("should show delete confirmation dialog when delete tapped", (
      tester,
    ) async {
      final profile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => [profile]);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap delete button
      final deleteButton = find.descendant(
        of: find.byType(ProfileListItem),
        matching: find.byIcon(Icons.delete),
      );

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining("Are you sure"), findsOneWidget);
      expect(find.textContaining("Alice"), findsOneWidget);
    });

    testWidgets("should delete profile when deletion confirmed", (
      tester,
    ) async {
      final profile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => [profile]);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);
      when(mockRepository.setActiveProfileId("1")).thenAnswer((_) async => {});

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.descendant(
        of: find.byType(ProfileListItem),
        matching: find.byIcon(Icons.delete),
      );

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.byKey(const Key("profile_delete_confirm_button")));
      await tester.pumpAndSettle();

      verify(mockRepository.deleteProfile("1")).called(1);
      expect(find.text("Profile deleted"), findsOneWidget);
    });

    testWidgets("should not delete profile when deletion cancelled", (
      tester,
    ) async {
      final profile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );

      when(mockRepository.getAllProfiles()).thenAnswer((_) async => [profile]);
      when(
        mockRepository.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.alphabetical);
      when(mockRepository.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const UserProfilePage(),
          userProfileRepository: mockRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.descendant(
        of: find.byType(ProfileListItem),
        matching: find.byIcon(Icons.delete),
      );

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.byKey(const Key("profile_delete_cancel_button")));
      await tester.pumpAndSettle();

      verifyNever(mockRepository.deleteProfile(any));
      expect(find.text("Profile deleted"), findsNothing);
    });
  });
}
