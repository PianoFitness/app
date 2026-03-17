import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/user_profile/widgets/profile_delete_confirmation_dialog.dart";

void main() {
  group("ProfileDeleteConfirmationDialog", () {
    const testProfileName = "Alice";

    /// Helper function to pump the dialog and open it.
    Future<void> pumpProfileDeleteDialog(
      WidgetTester tester, {
      String profileName = testProfileName,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      ProfileDeleteConfirmationDialog(profileName: profileName),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }

    /// Helper function to pump the dialog with result capture.
    ///
    /// The [resultContainer] is a list that will receive the dialog result
    /// at index 0 after a dialog button is tapped.
    Future<void> pumpDialogWithResult(
      WidgetTester tester,
      List<bool?> resultContainer, {
      String profileName = testProfileName,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  resultContainer[0] = await showDialog<bool>(
                    context: context,
                    builder: (context) => ProfileDeleteConfirmationDialog(
                      profileName: profileName,
                    ),
                  );
                },
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }

    testWidgets("should display all dialog elements", (tester) async {
      await pumpProfileDeleteDialog(tester);

      expect(find.text("Delete Profile?"), findsOneWidget);
      expect(find.textContaining("All practice data"), findsOneWidget);
      expect(
        find.textContaining("This action cannot be undone"),
        findsOneWidget,
      );
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);
    });

    testWidgets("should include profile name in warning message", (
      tester,
    ) async {
      await pumpProfileDeleteDialog(tester);

      expect(find.textContaining('"$testProfileName"'), findsOneWidget);
      expect(
        find.text(
          'All practice data, settings, and progress for "$testProfileName" will be permanently deleted.',
        ),
        findsOneWidget,
      );
    });

    testWidgets("should return false when cancel button tapped", (
      tester,
    ) async {
      final result = <bool?>[null];
      await pumpDialogWithResult(tester, result);

      await tester.tap(find.byKey(const Key("profile_delete_cancel_button")));
      await tester.pumpAndSettle();

      expect(result[0], isFalse);
      expect(find.byType(ProfileDeleteConfirmationDialog), findsNothing);
    });

    testWidgets("should return true when delete button tapped", (tester) async {
      final result = <bool?>[null];
      await pumpDialogWithResult(tester, result);

      await tester.tap(find.byKey(const Key("profile_delete_confirm_button")));
      await tester.pumpAndSettle();

      expect(result[0], isTrue);
      expect(find.byType(ProfileDeleteConfirmationDialog), findsNothing);
    });

    testWidgets("should style delete button with error color", (tester) async {
      await pumpProfileDeleteDialog(tester);

      final deleteButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text("Delete"),
          matching: find.byType(FilledButton),
        ),
      );

      // Verify error color is used
      expect(deleteButton.style, isNotNull);
      final buttonStyle = deleteButton.style!;
      final backgroundColor = buttonStyle.backgroundColor?.resolve({
        WidgetState.pressed,
      });

      // Get the theme error color for comparison
      final context = tester.element(
        find.byType(ProfileDeleteConfirmationDialog),
      );
      final expectedErrorColor = Theme.of(context).colorScheme.error;

      // The button should use the error color
      expect(backgroundColor, equals(expectedErrorColor));
    });

    testWidgets("should display warning text in bold", (tester) async {
      await pumpProfileDeleteDialog(tester);

      final warningText = tester.widget<Text>(
        find.text("This action cannot be undone."),
      );

      expect(warningText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets("should handle different profile names correctly", (
      tester,
    ) async {
      const specialName = "Test & User <with> \"Special\" 'Characters'";

      await pumpProfileDeleteDialog(tester, profileName: specialName);

      expect(find.textContaining(specialName), findsOneWidget);
    });
  });
}
