import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/user_profile.dart";
import "package:piano_fitness/presentation/features/user_profile/widgets/profile_list_item.dart";

void main() {
  group("ProfileListItem", () {
    late UserProfile testProfile;
    late bool tapCalled;
    late bool editCalled;
    late bool deleteCalled;

    setUp(() {
      testProfile = UserProfile(
        id: "1",
        displayName: "Alice",
        createdAt: DateTime(2026),
      );
      tapCalled = false;
      editCalled = false;
      deleteCalled = false;
    });

    Widget createTestWidget(UserProfile profile, {DateTime? now}) {
      return MaterialApp(
        home: Scaffold(
          body: ProfileListItem(
            profile: profile,
            onTap: () {
              tapCalled = true;
            },
            onEdit: () {
              editCalled = true;
            },
            onDelete: () {
              deleteCalled = true;
            },
            nowOverride: now,
          ),
        ),
      );
    }

    testWidgets("should display profile display name", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(find.text("Alice"), findsOneWidget);

      final displayNameText = tester.widget<Text>(find.text("Alice"));
      expect(displayNameText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets(
      "should display 'Never practiced' when lastPracticeDate is null",
      (tester) async {
        await tester.pumpWidget(createTestWidget(testProfile));

        expect(find.text("Never practiced"), findsOneWidget);
      },
    );

    testWidgets("should display 'Last practiced today' for today's practice", (
      tester,
    ) async {
      final profileWithTodayPractice = testProfile.copyWith(
        lastPracticeDate: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(profileWithTodayPractice));

      expect(find.text("Last practiced today"), findsOneWidget);
    });

    testWidgets(
      "should display 'Last practiced yesterday' for yesterday's practice",
      (tester) async {
        final profileWithYesterdayPractice = testProfile.copyWith(
          lastPracticeDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        await tester.pumpWidget(createTestWidget(profileWithYesterdayPractice));

        expect(find.text("Last practiced yesterday"), findsOneWidget);
      },
    );

    testWidgets("should display 'X days ago' for practice within last week", (
      tester,
    ) async {
      final profileWith3DaysAgo = testProfile.copyWith(
        lastPracticeDate: DateTime.now().subtract(const Duration(days: 3)),
      );

      await tester.pumpWidget(createTestWidget(profileWith3DaysAgo));

      expect(find.text("Last practiced 3 days ago"), findsOneWidget);
    });

    testWidgets("should display '1 week ago' for practice exactly 7 days ago", (
      tester,
    ) async {
      final profileWith7DaysAgo = testProfile.copyWith(
        lastPracticeDate: DateTime.now().subtract(const Duration(days: 7)),
      );

      await tester.pumpWidget(createTestWidget(profileWith7DaysAgo));

      expect(find.text("Last practiced 1 week ago"), findsOneWidget);
    });

    testWidgets("should display '1 week ago' for practice 10 days ago", (
      tester,
    ) async {
      final profileWith10DaysAgo = testProfile.copyWith(
        lastPracticeDate: DateTime.now().subtract(const Duration(days: 10)),
      );

      await tester.pumpWidget(createTestWidget(profileWith10DaysAgo));

      expect(find.text("Last practiced 1 week ago"), findsOneWidget);
    });

    testWidgets(
      "should display '2 weeks ago' for practice exactly 14 days ago",
      (tester) async {
        final profileWith14DaysAgo = testProfile.copyWith(
          lastPracticeDate: DateTime.now().subtract(const Duration(days: 14)),
        );

        await tester.pumpWidget(createTestWidget(profileWith14DaysAgo));

        expect(find.text("Last practiced 2 weeks ago"), findsOneWidget);
      },
    );

    testWidgets("should display '3 weeks ago' for practice 21 days ago", (
      tester,
    ) async {
      final profileWith3WeeksAgo = testProfile.copyWith(
        lastPracticeDate: DateTime.now().subtract(const Duration(days: 21)),
      );

      await tester.pumpWidget(createTestWidget(profileWith3WeeksAgo));

      expect(find.text("Last practiced 3 weeks ago"), findsOneWidget);
    });

    testWidgets("should display '1 month ago' for practice ~5 weeks ago", (
      tester,
    ) async {
      // Fixed: now = March 15 2026, lastPractice = Feb 10 2026 → months = 1
      final fixedNow = DateTime(2026, 3, 15);
      final profileWith5WeeksAgo = testProfile.copyWith(
        lastPracticeDate: DateTime(2026, 2, 10),
      );

      await tester.pumpWidget(
        createTestWidget(profileWith5WeeksAgo, now: fixedNow),
      );

      expect(find.text("Last practiced 1 month ago"), findsOneWidget);
    });

    testWidgets("should display '3 months ago' for practice ~95 days ago", (
      tester,
    ) async {
      // Fixed: now = March 15 2026, lastPractice = Dec 10 2025 → months = 3
      final fixedNow = DateTime(2026, 3, 15);
      final profileWith3MonthsAgo = testProfile.copyWith(
        lastPracticeDate: DateTime(2025, 12, 10),
      );

      await tester.pumpWidget(
        createTestWidget(profileWith3MonthsAgo, now: fixedNow),
      );

      expect(find.text("Last practiced 3 months ago"), findsOneWidget);
    });

    testWidgets("should display '1 year ago' for practice ~400 days ago", (
      tester,
    ) async {
      // Fixed: now = March 15 2026, lastPractice = Jan 10 2025 → months = 14 → 1 year
      final fixedNow = DateTime(2026, 3, 15);
      final profileWith1YearAgo = testProfile.copyWith(
        lastPracticeDate: DateTime(2025, 1, 10),
      );

      await tester.pumpWidget(
        createTestWidget(profileWith1YearAgo, now: fixedNow),
      );

      expect(find.text("Last practiced 1 year ago"), findsOneWidget);
    });

    testWidgets("should display '2 years ago' for practice 730+ days ago", (
      tester,
    ) async {
      // Fixed: now = March 15 2026, lastPractice = Jan 10 2024 → months = 26 → 2 years
      final fixedNow = DateTime(2026, 3, 15);
      final profileWith2YearsAgo = testProfile.copyWith(
        lastPracticeDate: DateTime(2024, 1, 10),
      );

      await tester.pumpWidget(
        createTestWidget(profileWith2YearsAgo, now: fixedNow),
      );

      expect(find.text("Last practiced 2 years ago"), findsOneWidget);
    });

    testWidgets("should call onTap when profile card is tapped", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(tapCalled, isFalse);

      await tester.tap(find.byKey(const Key("profile_list_item_1")));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets("should display edit button with correct icon", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);
    });

    testWidgets("should display edit button tooltip", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final editButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.edit),
          matching: find.byType(IconButton),
        ),
      );

      expect(editButton.tooltip, equals("Edit Alice"));
    });

    testWidgets("should call onEdit when edit button is tapped", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(editCalled, isFalse);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets("should have minimum touch target size for edit button", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final editButtonFinder = find.ancestor(
        of: find.byIcon(Icons.edit),
        matching: find.byType(IconButton),
      );

      final editButton = tester.widget<IconButton>(editButtonFinder);

      expect(editButton.constraints?.minWidth, greaterThanOrEqualTo(44));
      expect(editButton.constraints?.minHeight, greaterThanOrEqualTo(44));
    });

    testWidgets("should display delete button with correct icon", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
    });

    testWidgets("should display delete button tooltip", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final deleteButton = tester.widget<IconButton>(
        find
            .ancestor(
              of: find.byIcon(Icons.delete),
              matching: find.byType(IconButton),
            )
            .last,
      );

      expect(deleteButton.tooltip, equals("Delete Alice"));
    });

    testWidgets("should display delete button with error color", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final context = tester.element(find.byType(ProfileListItem));
      final expectedErrorColor = Theme.of(context).colorScheme.error;

      final deleteButton = tester.widget<IconButton>(
        find
            .ancestor(
              of: find.byIcon(Icons.delete),
              matching: find.byType(IconButton),
            )
            .last,
      );

      expect(deleteButton.color, equals(expectedErrorColor));
    });

    testWidgets("should call onDelete when delete button is tapped", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(deleteCalled, isFalse);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets("should have minimum touch target size for delete button", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final deleteButtonFinder = find
          .ancestor(
            of: find.byIcon(Icons.delete),
            matching: find.byType(IconButton),
          )
          .last;

      final deleteButton = tester.widget<IconButton>(deleteButtonFinder);

      expect(deleteButton.constraints?.minWidth, greaterThanOrEqualTo(44));
      expect(deleteButton.constraints?.minHeight, greaterThanOrEqualTo(44));
    });

    testWidgets("should handle long display names with ellipsis", (
      tester,
    ) async {
      // Create a name that is exactly 30 characters
      const longName = "Abcdefghijklmnopqrstuvwxyz123";
      final longNameProfile = testProfile.copyWith(displayName: longName);

      await tester.pumpWidget(createTestWidget(longNameProfile));

      expect(find.text(longName), findsOneWidget);

      final displayNameText = tester.widget<Text>(find.text(longName));
      expect(displayNameText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets("should render as a Card with proper styling", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(find.byType(Card), findsOneWidget);
      // Card has 1 InkWell, edit button has 1, delete button has 1 = 3 total
      expect(find.byType(InkWell), findsNWidgets(3));

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        card.margin,
        equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      );
    });

    testWidgets("should have proper layout with all elements", (tester) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      expect(find.text("Alice"), findsOneWidget);
      expect(find.text("Never practiced"), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets("should update tooltip when profile name changes", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testProfile));

      final editButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.edit),
          matching: find.byType(IconButton),
        ),
      );

      expect(editButton.tooltip, equals("Edit Alice"));

      // Update with new profile
      final newProfile = testProfile.copyWith(displayName: "Bob");
      await tester.pumpWidget(createTestWidget(newProfile));

      final updatedEditButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.edit),
          matching: find.byType(IconButton),
        ),
      );

      expect(updatedEditButton.tooltip, equals("Edit Bob"));
    });
  });
}
