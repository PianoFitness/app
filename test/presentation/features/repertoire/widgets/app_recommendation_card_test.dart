import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/app_recommendation_card.dart";

void main() {
  group("AppRecommendationCard Widget Tests", () {
    testWidgets("renders app name, description, and responds to tap", (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppRecommendationCard(
              name: "forScore",
              description: "Digital sheet music reader",
              url: "https://forscore.co",
              icon: Icons.music_note,
              color: Colors.blue,
              onOpenUrl: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text("forScore"), findsOneWidget);
      expect(find.text("Digital sheet music reader"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.open_in_new));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
