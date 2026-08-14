import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";

import "../../../shared/midi_mocks.dart";
import "../../../shared/test_helpers/pump_helpers.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";

Future<void> _openPianoReference(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key("nav_tab_piano")));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Reference"));
  await tester.pumpAndSettle();
}

Future<void> _selectReferenceMode(
  WidgetTester tester,
  ReferenceMode mode,
) async {
  final dropdown = find.byType(DropdownButtonFormField<ReferenceMode>);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(mode == ReferenceMode.scales ? "Scales" : "Chords").last,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("Piano reference integration", () {
    testWidgets("opens Reference as a mode of the Piano destination", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));

      await _openPianoReference(tester);

      expect(find.text("Piano"), findsWidgets);
      expect(find.byKey(const Key("piano_mode_switch")), findsOneWidget);
      expect(
        find.byType(DropdownButtonFormField<ReferenceMode>),
        findsOneWidget,
      );
      expect(find.byKey(const Key("reference_piano")), findsOneWidget);
    });

    testWidgets("preserves reference choices when switching Piano modes", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));
      await _openPianoReference(tester);
      await _selectReferenceMode(tester, ReferenceMode.chordTypes);

      await tester.tap(find.text("Play"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButtonFormField<ReferenceMode>>(
        find.byType(DropdownButtonFormField<ReferenceMode>),
      );
      expect(dropdown.initialValue, ReferenceMode.chordTypes);
    });

    testWidgets("preserves Piano state while visiting another destination", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));
      await _openPianoReference(tester);
      await _selectReferenceMode(tester, ReferenceMode.chordTypes);

      await tester.tap(find.byKey(const Key("nav_tab_curriculum")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("nav_tab_piano")));
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButtonFormField<ReferenceMode>>(
        find.byType(DropdownButtonFormField<ReferenceMode>),
      );
      expect(dropdown.initialValue, ReferenceMode.chordTypes);
    });
  });
}
