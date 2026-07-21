import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_timer_display.dart";

void main() {
  group("RepertoireTimerDisplay Widget Tests", () {
    testWidgets("renders timer display and controls when ready", (
      WidgetTester tester,
    ) async {
      bool startCalled = false;

      const state = TimerState(
        formattedTime: "05:00",
        progress: 1.0,
        isRunning: false,
        isPaused: false,
        remainingSeconds: 300,
        selectedDurationMinutes: 5,
      );

      final actions = TimerActions(
        canStart: true,
        canResume: false,
        canPause: false,
        canReset: false,
        onStart: () => startCalled = true,
        onResume: () {},
        onPause: () {},
        onReset: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: RepertoireTimerDisplay(state: state, actions: actions),
              ),
            ),
          ),
        ),
      );

      expect(find.text("05:00"), findsOneWidget);
      expect(find.text("Ready to Start"), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      expect(startCalled, isTrue);
    });

    testWidgets("renders pause and reset buttons when running", (
      WidgetTester tester,
    ) async {
      bool pauseCalled = false;
      bool resetCalled = false;

      const state = TimerState(
        formattedTime: "04:30",
        progress: 0.9,
        isRunning: true,
        isPaused: false,
        remainingSeconds: 270,
        selectedDurationMinutes: 5,
      );

      final actions = TimerActions(
        canStart: false,
        canResume: false,
        canPause: true,
        canReset: true,
        onStart: () {},
        onResume: () {},
        onPause: () => pauseCalled = true,
        onReset: () => resetCalled = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: RepertoireTimerDisplay(state: state, actions: actions),
              ),
            ),
          ),
        ),
      );

      expect(find.text("04:30"), findsOneWidget);
      expect(find.text("Timer Running"), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause));
      expect(pauseCalled, isTrue);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(resetCalled, isTrue);
    });
  });
}
