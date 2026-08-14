import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/presentation/features/piano/piano_page.dart";
import "package:piano_fitness/presentation/features/piano/widgets/twelve_tone_circle.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";

import "../../../shared/midi_mocks.dart";
import "../../../shared/test_helpers/pump_helpers.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";

Future<void> _openPiano(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key("nav_tab_piano")));
  await tester.pumpAndSettle();
}

Future<void> _openReferencePicker(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key("piano_show_notes_button")));
  await tester.pumpAndSettle();
}

Future<void> _selectChordMode(WidgetTester tester) async {
  final selector = find.byKey(const Key("reference_kind_selector"));
  await tester.tap(find.descendant(of: selector, matching: find.text("Chord")));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("Piano reference integration", () {
    testWidgets("uses one balanced, always-playable piano surface", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));

      await _openPiano(tester);

      expect(find.text("Play freely"), findsOneWidget);
      expect(find.byKey(const Key("piano_mode_switch")), findsNothing);
      expect(find.byKey(const Key("piano_keyboard")), findsOneWidget);
      expect(find.byKey(const Key("piano_show_notes_button")), findsOneWidget);
      expect(find.byKey(const Key("twelve_tone_circle")), findsOneWidget);

      final stageSize = tester.getSize(find.byKey(const Key("piano_stage")));
      expect(stageSize.width, 390);
      expect(stageSize.height, lessThanOrEqualTo(240));
      expect(stageSize.height, lessThan(844 * 0.5));

      final piano = tester.widget<PianoKeyboard>(
        find.byKey(const Key("piano_keyboard")),
      );
      expect(piano.noteLabelMode, NoteLabelMode.none);
      expect(piano.range, const MidiNoteRange(fromMidi: 48, toMidi: 72));
      expect(piano.minimumKeyWidth, 20);
    });

    testWidgets("shows two to four octaves as the available width grows", (
      tester,
    ) async {
      Future<MidiNoteRange> rangeAt(Size size) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(createTestWidget(const PianoPage()));
        await tester.pumpAndSettle();
        return tester
            .widget<PianoKeyboard>(find.byKey(const Key("piano_keyboard")))
            .range;
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      expect(
        await rangeAt(const Size(390, 844)),
        const MidiNoteRange(fromMidi: 48, toMidi: 72),
      );
      expect(
        await rangeAt(const Size(700, 900)),
        const MidiNoteRange(fromMidi: 48, toMidi: 84),
      );
      expect(
        await rangeAt(const Size(1100, 900)),
        const MidiNoteRange(fromMidi: 36, toMidi: 84),
      );
    });

    testWidgets("shows reference choices with a clear information hierarchy", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));
      await _openPiano(tester);
      await _openReferencePicker(tester);

      expect(find.text("Show notes"), findsWidgets);
      expect(find.text("Type"), findsOneWidget);
      expect(find.byKey(const Key("reference_kind_selector")), findsOneWidget);
      expect(find.text("Selection"), findsOneWidget);
      expect(find.text("Voicing"), findsNothing);

      await _selectChordMode(tester);

      expect(find.text("Voicing"), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<ChordType>), findsOneWidget);
    });

    testWidgets("applies and clears highlighted reference notes", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));
      await _openPiano(tester);
      await _openReferencePicker(tester);
      await _selectChordMode(tester);
      await tester.tap(find.byKey(const Key("reference_picker_apply")));
      await tester.pumpAndSettle();

      expect(find.text("C Major"), findsOneWidget);
      expect(find.textContaining("Root Position"), findsOneWidget);
      expect(find.byKey(const Key("piano_clear_reference")), findsOneWidget);

      final toneCircle = tester.widget<TwelveToneCircle>(
        find.byType(TwelveToneCircle),
      );
      expect(toneCircle.selectedPitchClasses, {0, 4, 7});

      final piano = tester.widget<PianoKeyboard>(
        find.byKey(const Key("piano_keyboard")),
      );
      expect(piano.noteLabelMode, NoteLabelMode.name);
      expect(piano.range, const MidiNoteRange(fromMidi: 48, toMidi: 72));

      await tester.tap(find.byKey(const Key("piano_clear_reference")));
      await tester.pumpAndSettle();
      expect(find.text("Play freely"), findsOneWidget);
      expect(find.byKey(const Key("piano_clear_reference")), findsNothing);
      expect(
        tester
            .widget<TwelveToneCircle>(find.byType(TwelveToneCircle))
            .selectedPitchClasses,
        isEmpty,
      );
    });

    testWidgets("keeps the selected reference while visiting another section", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestWidget(const MainNavigation()));
      await _openPiano(tester);
      await _openReferencePicker(tester);
      await _selectChordMode(tester);
      await tester.tap(find.byKey(const Key("reference_picker_apply")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("nav_tab_curriculum")));
      await tester.pumpAndSettle();
      await _openPiano(tester);

      expect(find.text("C Major"), findsOneWidget);
      expect(find.byKey(const Key("piano_clear_reference")), findsOneWidget);
    });
  });
}
