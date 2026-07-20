import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/presentation/features/reference/reference_page.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";
import "../../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("ReferencePage Widget Tests", () {
    // The configuration row uses DropdownButtonFormField, one per generic
    // type, so each is uniquely addressable by its runtime type rather than
    // by label/value text (which changes as selections change).
    Future<void> selectMode(WidgetTester tester, ReferenceMode mode) async {
      final dropdown = tester.widget<DropdownButtonFormField<ReferenceMode>>(
        find.byType(DropdownButtonFormField<ReferenceMode>),
      );
      dropdown.onChanged!(mode);
      await tester.pumpAndSettle();
    }

    Future<void> selectKey(WidgetTester tester, scales.Key key) async {
      final dropdown = tester.widget<DropdownButtonFormField<scales.Key>>(
        find.byType(DropdownButtonFormField<scales.Key>),
      );
      dropdown.onChanged!(key);
      await tester.pumpAndSettle();
    }

    Future<void> selectScaleType(
      WidgetTester tester,
      scales.ScaleType type,
    ) async {
      final dropdown = tester
          .widget<DropdownButtonFormField<scales.ScaleType>>(
            find.byType(DropdownButtonFormField<scales.ScaleType>),
          );
      dropdown.onChanged!(type);
      await tester.pumpAndSettle();
    }

    Future<void> selectChordType(WidgetTester tester, ChordType type) async {
      final dropdown = tester.widget<DropdownButtonFormField<ChordType>>(
        find.byType(DropdownButtonFormField<ChordType>),
      );
      dropdown.onChanged!(type);
      await tester.pumpAndSettle();
    }

    Future<void> selectChordInversion(
      WidgetTester tester,
      ChordInversion inversion,
    ) async {
      final dropdown = tester
          .widget<DropdownButtonFormField<ChordInversion>>(
            find.byType(DropdownButtonFormField<ChordInversion>),
          );
      dropdown.onChanged!(inversion);
      await tester.pumpAndSettle();
    }

    testWidgets("should display reference page with initial content", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      // Initially in scales mode: mode, key, and scale type dropdowns.
      expect(
        find.byType(DropdownButtonFormField<ReferenceMode>),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<scales.Key>), findsOneWidget);
      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<ChordType>), findsNothing);
      expect(
        find.byType(DropdownButtonFormField<ChordInversion>),
        findsNothing,
      );

      final modeDropdown = tester
          .widget<DropdownButtonFormField<ReferenceMode>>(
            find.byType(DropdownButtonFormField<ReferenceMode>),
          );
      expect(modeDropdown.initialValue, ReferenceMode.scales);
    });

    testWidgets("should switch between scales and chords mode", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<ChordType>), findsNothing);

      await selectMode(tester, ReferenceMode.chordTypes);

      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsNothing,
      );
      expect(find.byType(DropdownButtonFormField<ChordType>), findsOneWidget);
      expect(
        find.byType(DropdownButtonFormField<ChordInversion>),
        findsOneWidget,
      );

      await selectMode(tester, ReferenceMode.scales);

      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<ChordType>), findsNothing);
    });

    testWidgets("should allow selection of different keys", (tester) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectKey(tester, scales.Key.fSharp);

      final keyDropdown = tester.widget<DropdownButtonFormField<scales.Key>>(
        find.byType(DropdownButtonFormField<scales.Key>),
      );
      expect(keyDropdown.initialValue, scales.Key.fSharp);
    });

    testWidgets("should allow selection of different scale types", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectScaleType(tester, scales.ScaleType.minor);

      final typeDropdown = tester
          .widget<DropdownButtonFormField<scales.ScaleType>>(
            find.byType(DropdownButtonFormField<scales.ScaleType>),
          );
      expect(typeDropdown.initialValue, scales.ScaleType.minor);
    });

    testWidgets("should allow selection of different chord types", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectMode(tester, ReferenceMode.chordTypes);
      await selectChordType(tester, ChordType.minor);

      final typeDropdown = tester.widget<DropdownButtonFormField<ChordType>>(
        find.byType(DropdownButtonFormField<ChordType>),
      );
      expect(typeDropdown.initialValue, ChordType.minor);
    });

    testWidgets("should allow selection of different chord inversions", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectMode(tester, ReferenceMode.chordTypes);
      await selectChordInversion(tester, ChordInversion.first);

      final inversionDropdown = tester
          .widget<DropdownButtonFormField<ChordInversion>>(
            find.byType(DropdownButtonFormField<ChordInversion>),
          );
      expect(inversionDropdown.initialValue, ChordInversion.first);
    });

    testWidgets("should display interactive piano", (tester) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      expect(find.byType(PianoKeyboard), findsOneWidget);
    });

    testWidgets("should update piano when scale selection changes", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectScaleType(tester, scales.ScaleType.minor);

      expect(find.byType(PianoKeyboard), findsOneWidget);

      final typeDropdown = tester
          .widget<DropdownButtonFormField<scales.ScaleType>>(
            find.byType(DropdownButtonFormField<scales.ScaleType>),
          );
      expect(typeDropdown.initialValue, scales.ScaleType.minor);
    });

    testWidgets("should update piano when chord selection changes", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ReferencePage()));
      await tester.pumpAndSettle();

      await selectMode(tester, ReferenceMode.chordTypes);
      await selectChordType(tester, ChordType.minor);

      expect(find.byType(PianoKeyboard), findsOneWidget);

      final typeDropdown = tester.widget<DropdownButtonFormField<ChordType>>(
        find.byType(DropdownButtonFormField<ChordType>),
      );
      expect(typeDropdown.initialValue, ChordType.minor);
    });

    testWidgets(
      "should tightly frame the piano range around the selected scale",
      (tester) async {
        await tester.pumpWidget(createTestWidget(const ReferencePage()));
        await tester.pumpAndSettle();

        // Default is a C major scale (MIDI 60-71, base octave 4), so the
        // keyboard should hug that range rather than spanning a fixed
        // multi-octave window centered elsewhere.
        final piano = tester.widget<PianoKeyboard>(find.byType(PianoKeyboard));
        expect(piano.range.fromMidi, lessThanOrEqualTo(60));
        expect(piano.range.toMidi, greaterThanOrEqualTo(71));
        // The range should stay close (within a handful of keys) rather
        // than falling back to a wide, mostly-empty keyboard.
        expect(piano.range.toMidi - piano.range.fromMidi, lessThan(24));
      },
    );

    group("Piano Interaction", () {
      testWidgets("should handle piano key taps", (tester) async {
        final mockMidiRepository = MockIMidiRepository();
        await tester.pumpWidget(
          createTestWidgetWithMocks(
            child: const ReferencePage(),
            midiRepository: mockMidiRepository,
          ),
        );
        await tester.pumpAndSettle();

        final pianoFinder = find.byType(PianoKeyboard);
        expect(pianoFinder, findsOneWidget);

        final piano = tester.widget<PianoKeyboard>(pianoFinder);
        expect(piano.onKeyDown, isNotNull);
        expect(piano.onKeyUp, isNotNull);

        piano.onKeyDown!(60);
        await tester.pump();
        verify(mockMidiRepository.sendNoteOn(60, 64, 0)).called(1);

        piano.onKeyUp!(60);
        await tester.pump();
        verify(mockMidiRepository.sendNoteOff(60, 0)).called(1);
      });
    });

    group("Error Handling", () {
      testWidgets("should handle initialization with provider correctly", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const ReferencePage()));

        await tester.pumpAndSettle();
        expect(find.byType(PianoKeyboard), findsOneWidget);
      });
    });
  });
}
