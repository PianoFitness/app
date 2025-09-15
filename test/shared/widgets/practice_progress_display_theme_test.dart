import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/widgets/practice_progress_display.dart";

void main() {
  group("PracticeProgressDisplay Theme Tests", () {
    testWidgets("uses theme colors in light mode", (WidgetTester tester) async {
      // Create test chord progression
      final testChordProgression = [
        ChordInfo(
          name: "C Major",
          notes: [MusicalNote.c, MusicalNote.e, MusicalNote.g],
          type: ChordType.major,
          inversion: ChordInversion.root,
          rootNote: MusicalNote.c,
        ),
        ChordInfo(
          name: "G Major",
          notes: [MusicalNote.g, MusicalNote.b, MusicalNote.d],
          type: ChordType.major,
          inversion: ChordInversion.root,
          rootNote: MusicalNote.g,
        ),
      ];

      // Build widget with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: true,
              currentSequence: [60, 62, 64, 65, 67, 69, 71, 72],
              currentNoteIndex: 3,
              currentChordIndex: 0,
              currentChordProgression: testChordProgression,
            ),
          ),
        ),
      );

      // Verify progress indicator is shown
      expect(find.text("Progress: 4/8"), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify the container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(const Key("ppd_container")))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);
    });

    testWidgets("uses theme colors in dark mode", (WidgetTester tester) async {
      // Create test chord progression
      final testChordProgression = [
        ChordInfo(
          name: "C Major",
          notes: [MusicalNote.c, MusicalNote.e, MusicalNote.g],
          type: ChordType.major,
          inversion: ChordInversion.root,
          rootNote: MusicalNote.c,
        ),
        ChordInfo(
          name: "G Major",
          notes: [MusicalNote.g, MusicalNote.b, MusicalNote.d],
          type: ChordType.major,
          inversion: ChordInversion.root,
          rootNote: MusicalNote.g,
        ),
      ];

      // Build widget with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.chordProgressions,
              practiceActive: true,
              currentSequence: [60, 64, 67],
              currentNoteIndex: 0,
              currentChordIndex: 0,
              currentChordProgression: testChordProgression,
            ),
          ),
        ),
      );

      // Verify progression text and chord name are shown
      expect(find.text("Progression 1/2"), findsOneWidget);
      expect(find.text("C Major"), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify the container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(const Key("ppd_container")))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);
    });

    testWidgets("hides when practice is not active", (
      WidgetTester tester,
    ) async {
      // Build widget with practice inactive
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: false,
              currentSequence: [60, 62, 64],
              currentNoteIndex: 0,
              currentChordIndex: 0,
              currentChordProgression: [],
            ),
          ),
        ),
      );

      // Should show nothing when practice is not active
      expect(find.byType(Container), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets("hides when sequence is empty", (WidgetTester tester) async {
      // Build widget with empty sequence
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: true,
              currentSequence: [],
              currentNoteIndex: 0,
              currentChordIndex: 0,
              currentChordProgression: [],
            ),
          ),
        ),
      );

      // Should show nothing when sequence is empty
      expect(find.byType(Container), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
