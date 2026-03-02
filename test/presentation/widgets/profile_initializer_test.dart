import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/user_profile.dart";
import "package:piano_fitness/features/user_profile/user_profile_page.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "package:piano_fitness/presentation/widgets/profile_initializer.dart";

import "../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../shared/test_helpers/widget_test_helper.dart";

void main() {
  group("ProfileInitializer", () {
    late MockIUserProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockIUserProfileRepository();
    });

    testWidgets("should show loading indicator initially", (tester) async {
      when(mockRepository.getAllProfiles()).thenAnswer(
        (_) async => Future.delayed(const Duration(seconds: 1), () => []),
      );

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const ProfileInitializer(),
          userProfileRepository: mockRepository,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    group("0 profiles (first launch)", () {
      testWidgets("should navigate to UserProfilePage when no profiles exist", (
        tester,
      ) async {
        when(mockRepository.getAllProfiles()).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const ProfileInitializer(),
            userProfileRepository: mockRepository,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(UserProfilePage), findsOneWidget);
        expect(find.byType(MainNavigation), findsNothing);
      });

      testWidgets("should re-initialize after returning from UserProfilePage", (
        tester,
      ) async {
        final profile = UserProfile(
          id: "1",
          displayName: "Test User",
          createdAt: DateTime(2026),
        );

        // First call: no profiles
        // Second call (after profile created): one profile
        var callCount = 0;
        when(mockRepository.getAllProfiles()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? [] : [profile];
        });

        when(
          mockRepository.setActiveProfileId("1"),
        ).thenAnswer((_) async => {});

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const ProfileInitializer(),
            userProfileRepository: mockRepository,
          ),
        );

        await tester.pumpAndSettle();

        // Should show UserProfilePage initially
        expect(find.byType(UserProfilePage), findsOneWidget);

        // Simulate user creating profile and returning
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        navigator.pop();
        await tester.pumpAndSettle();

        // Should re-initialize and now navigate to MainNavigation
        expect(find.byType(MainNavigation), findsOneWidget);
        expect(find.byType(UserProfilePage), findsNothing);
        verify(mockRepository.setActiveProfileId("1")).called(1);
      });
    });

    group("1 profile", () {
      testWidgets(
        "should  auto-select profile and navigate to MainNavigation",
        (tester) async {
          final profile = UserProfile(
            id: "1",
            displayName: "Solo User",
            createdAt: DateTime(2026),
          );

          when(
            mockRepository.getAllProfiles(),
          ).thenAnswer((_) async => [profile]);
          when(
            mockRepository.setActiveProfileId("1"),
          ).thenAnswer((_) async => {});

          await tester.pumpWidget(
            createTestWidgetWithMocks(
              child: const ProfileInitializer(),
              userProfileRepository: mockRepository,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.byType(MainNavigation), findsOneWidget);
          expect(find.byType(UserProfilePage), findsNothing);
          verify(mockRepository.setActiveProfileId("1")).called(1);
        },
      );
    });

    group("multiple profiles", () {
      late List<UserProfile> profiles;

      setUp(() {
        profiles = [
          UserProfile(
            id: "1",
            displayName: "User One",
            createdAt: DateTime(2026),
          ),
          UserProfile(
            id: "2",
            displayName: "User Two",
            createdAt: DateTime(2026, 1, 2),
          ),
          UserProfile(
            id: "3",
            displayName: "User Three",
            createdAt: DateTime(2026, 1, 3),
          ),
        ];
      });

      testWidgets(
        "should navigate to MainNavigation when active profile ID is valid",
        (tester) async {
          when(
            mockRepository.getAllProfiles(),
          ).thenAnswer((_) async => profiles);
          when(
            mockRepository.getActiveProfileId(),
          ).thenAnswer((_) async => "2");

          await tester.pumpWidget(
            createTestWidgetWithMocks(
              child: const ProfileInitializer(),
              userProfileRepository: mockRepository,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.byType(MainNavigation), findsOneWidget);
          expect(find.byType(UserProfilePage), findsNothing);
        },
      );

      testWidgets(
        "should navigate to UserProfilePage when active profile ID is null",
        (tester) async {
          when(
            mockRepository.getAllProfiles(),
          ).thenAnswer((_) async => profiles);
          when(
            mockRepository.getActiveProfileId(),
          ).thenAnswer((_) async => null);

          await tester.pumpWidget(
            createTestWidgetWithMocks(
              child: const ProfileInitializer(),
              userProfileRepository: mockRepository,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.byType(UserProfilePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsNothing);
        },
      );

      testWidgets(
        "should navigate to UserProfilePage when active profile ID is invalid",
        (tester) async {
          when(
            mockRepository.getAllProfiles(),
          ).thenAnswer((_) async => profiles);
          when(
            mockRepository.getActiveProfileId(),
          ).thenAnswer((_) async => "999"); // Non-existent ID

          await tester.pumpWidget(
            createTestWidgetWithMocks(
              child: const ProfileInitializer(),
              userProfileRepository: mockRepository,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.byType(UserProfilePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsNothing);
        },
      );
    });

    group("error handling", () {
      testWidgets("should navigate to UserProfilePage on repository error", (
        tester,
      ) async {
        when(
          mockRepository.getAllProfiles(),
        ).thenThrow(Exception("Database error"));

        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const ProfileInitializer(),
            userProfileRepository: mockRepository,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(UserProfilePage), findsOneWidget);
        expect(find.byType(MainNavigation), findsNothing);
      });
    });
  });
}
