import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/user_profile/widgets/profile_create_dialog.dart";

void main() {
  group("ProfileCreateDialog", () {
    testWidgets("should display create profile dialog with all elements", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text("Create Profile"), findsOneWidget);
      expect(
        find.text("Enter your first name to create a new profile."),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Create"), findsOneWidget);
    });

    testWidgets("should have TextField with correct properties", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField),
          matching: find.byType(TextField),
        ),
      );

      expect(textField.autofocus, isTrue);
      expect(textField.maxLength, equals(30));
      expect(textField.decoration?.labelText, equals("Display Name"));
      expect(textField.decoration?.hintText, equals("Enter your first name"));
    });

    testWidgets("should show character counter for TextField", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Material Design shows character counter as "0/30" initially
      expect(find.text("0/30"), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), "Alice");
      await tester.pump();

      expect(find.text("5/30"), findsOneWidget);
    });

    testWidgets("should validate empty input", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to submit with empty input
      await tester.tap(find.byKey(const Key("profile_create_submit_button")));
      await tester.pumpAndSettle();

      expect(find.text("Display name cannot be empty"), findsOneWidget);
      // Dialog should still be open
      expect(find.byType(ProfileCreateDialog), findsOneWidget);
    });

    testWidgets("should validate whitespace-only input", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "   ");

      await tester.tap(find.byKey(const Key("profile_create_submit_button")));
      await tester.pumpAndSettle();

      expect(find.text("Display name cannot be empty"), findsOneWidget);
      expect(find.byType(ProfileCreateDialog), findsOneWidget);
    });

    testWidgets("should validate input exceeding 30 characters", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to enter 31 characters (should be limited by maxLength)
      const longName = "This is a very long display name that exceeds limit";
      await tester.enterText(find.byType(TextFormField), longName);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      final controller = textField.controller!;

      // TextField should enforce maxLength
      expect(controller.text.length, lessThanOrEqualTo(30));
    });

    testWidgets(
      "should return display name when create button tapped with valid input",
      (tester) async {
        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<String>(
                      context: context,
                      builder: (context) => const ProfileCreateDialog(),
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

        await tester.enterText(find.byType(TextFormField), "Alice");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("profile_create_submit_button")));
        await tester.pumpAndSettle();

        expect(result, equals("Alice"));
        // Dialog should be closed
        expect(find.byType(ProfileCreateDialog), findsNothing);
      },
    );

    testWidgets("should trim whitespace from display name", (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (context) => const ProfileCreateDialog(),
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

      await tester.enterText(find.byType(TextFormField), "  Alice  ");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("profile_create_submit_button")));
      await tester.pumpAndSettle();

      expect(result, equals("Alice"));
    });

    testWidgets("should return null when cancel button tapped", (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (context) => const ProfileCreateDialog(),
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

      await tester.enterText(find.byType(TextFormField), "Alice");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("profile_create_cancel_button")));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.byType(ProfileCreateDialog), findsNothing);
    });

    testWidgets("should submit on TextField enter key", (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (context) => const ProfileCreateDialog(),
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

      await tester.enterText(find.byType(TextFormField), "Bob");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result, equals("Bob"));
      expect(find.byType(ProfileCreateDialog), findsNothing);
    });

    testWidgets("should disable buttons during creation", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => const ProfileCreateDialog(),
                ),
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "Charlie");
      await tester.pumpAndSettle();

      // Tap create button
      await tester.tap(find.byKey(const Key("profile_create_submit_button")));
      // Only pump once to catch the state before dialog closes
      await tester.pump();

      // Verify the submit button is disabled during creation
      final submitButton = tester.widget<FilledButton>(
        find.byKey(const Key("profile_create_submit_button")),
      );
      expect(
        submitButton.onPressed,
        isNull,
        reason: "Submit button should be disabled during profile creation",
      );
    });
  });
}
