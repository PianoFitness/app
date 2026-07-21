import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_info_modal.dart";

void main() {
  group("RepertoireInfoModal Widget Tests", () {
    testWidgets("renders title, header, intro card, and recommendation items", (
      WidgetTester tester,
    ) async {
      String? launchedUrl;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepertoireInfoModal(
              onLaunchUrl: (url) {
                launchedUrl = url;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("About Repertoire Practice"), findsOneWidget);
      expect(find.text("Recommended Apps"), findsOneWidget);

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      final openButtons = find.byIcon(Icons.open_in_new);
      expect(openButtons, findsWidgets);

      await tester.tap(openButtons.first);
      await tester.pumpAndSettle();

      expect(launchedUrl, isNotNull);
    });
  });
}
