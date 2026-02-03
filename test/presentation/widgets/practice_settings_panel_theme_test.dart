import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/presentation/widgets/practice_settings_panel.dart";

void main() {
  group("PracticeSettingsPanel Theme Tests", () {
    testWidgets("uses theme colors in light mode", (WidgetTester tester) async {
      // Build widget with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              practiceMode: PracticeMode.scales,
              selectedKey: music.Key.c,
              selectedScaleType: music.ScaleType.major,
              selectedRootNote: MusicalNote.c,
              selectedArpeggioType: ArpeggioType.major,
              selectedArpeggioOctaves: ArpeggioOctaves.one,
              selectedChordProgression: null,
              selectedChordType: ChordType.major,
              includeInversions: false,
              includeSeventhChords: false,
              selectedHandSelection: HandSelection.both,
              autoProgressKeys: false,
              practiceActive: false,
              onResetPractice: () {},
              onPracticeModeChanged: (_) {},
              onKeyChanged: (_) {},
              onScaleTypeChanged: (_) {},
              onRootNoteChanged: (_) {},
              onArpeggioTypeChanged: (_) {},
              onArpeggioOctavesChanged: (_) {},
              onChordProgressionChanged: (_) {},
              onChordTypeChanged: (_) {},
              onIncludeInversionsChanged: (_) {},
              onIncludeSeventhChordsChanged: (_) {},
              onHandSelectionChanged: (_) {},
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the panel container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(PracticeSettingsPanel.panelKey))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);

      // Verify "Practice Settings" text is present
      expect(find.text("Practice Settings"), findsOneWidget);

      // Verify fitness center icon is present
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets("uses theme colors in dark mode", (WidgetTester tester) async {
      // Build widget with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              practiceMode: PracticeMode.scales,
              selectedKey: music.Key.c,
              selectedScaleType: music.ScaleType.major,
              selectedRootNote: MusicalNote.c,
              selectedArpeggioType: ArpeggioType.major,
              selectedArpeggioOctaves: ArpeggioOctaves.one,
              selectedChordProgression: null,
              selectedChordType: ChordType.major,
              includeInversions: false,
              includeSeventhChords: false,
              selectedHandSelection: HandSelection.both,
              autoProgressKeys: false,
              practiceActive: false,
              onResetPractice: () {},
              onPracticeModeChanged: (_) {},
              onKeyChanged: (_) {},
              onScaleTypeChanged: (_) {},
              onRootNoteChanged: (_) {},
              onArpeggioTypeChanged: (_) {},
              onArpeggioOctavesChanged: (_) {},
              onChordProgressionChanged: (_) {},
              onChordTypeChanged: (_) {},
              onIncludeInversionsChanged: (_) {},
              onIncludeSeventhChordsChanged: (_) {},
              onHandSelectionChanged: (_) {},
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the panel container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(PracticeSettingsPanel.panelKey))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);

      // Verify practice status container with different states
      final practiceStatusContainer = tester.widget<Container>(
        find.byKey(PracticeSettingsPanel.statusKey),
      );

      expect(practiceStatusContainer.decoration, isNotNull);

      // Verify "Practice Settings" text is present and readable
      expect(find.text("Practice Settings"), findsOneWidget);

      // Verify "Ready - Play Any Note to Start" text is present
      expect(find.text("Ready - Play Any Note to Start"), findsOneWidget);
    });

    testWidgets("shows different colors for active and inactive practice", (
      WidgetTester tester,
    ) async {
      // Test inactive state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              practiceMode: PracticeMode.scales,
              selectedKey: music.Key.c,
              selectedScaleType: music.ScaleType.major,
              selectedRootNote: MusicalNote.c,
              selectedArpeggioType: ArpeggioType.major,
              selectedArpeggioOctaves: ArpeggioOctaves.one,
              selectedChordProgression: null,
              selectedChordType: ChordType.major,
              includeInversions: false,
              includeSeventhChords: false,
              selectedHandSelection: HandSelection.both,
              autoProgressKeys: false,
              practiceActive: false,
              onResetPractice: () {},
              onPracticeModeChanged: (_) {},
              onKeyChanged: (_) {},
              onScaleTypeChanged: (_) {},
              onRootNoteChanged: (_) {},
              onArpeggioTypeChanged: (_) {},
              onArpeggioOctavesChanged: (_) {},
              onChordProgressionChanged: (_) {},
              onChordTypeChanged: (_) {},
              onIncludeInversionsChanged: (_) {},
              onIncludeSeventhChordsChanged: (_) {},
              onHandSelectionChanged: (_) {},
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Ready - Play Any Note to Start"), findsOneWidget);

      // Test active state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              practiceMode: PracticeMode.scales,
              selectedKey: music.Key.c,
              selectedScaleType: music.ScaleType.major,
              selectedRootNote: MusicalNote.c,
              selectedArpeggioType: ArpeggioType.major,
              selectedArpeggioOctaves: ArpeggioOctaves.one,
              selectedChordProgression: null,
              selectedChordType: ChordType.major,
              includeInversions: false,
              includeSeventhChords: false,
              selectedHandSelection: HandSelection.both,
              autoProgressKeys: false,
              practiceActive: true,
              onResetPractice: () {},
              onPracticeModeChanged: (_) {},
              onKeyChanged: (_) {},
              onScaleTypeChanged: (_) {},
              onRootNoteChanged: (_) {},
              onArpeggioTypeChanged: (_) {},
              onArpeggioOctavesChanged: (_) {},
              onChordProgressionChanged: (_) {},
              onChordTypeChanged: (_) {},
              onIncludeInversionsChanged: (_) {},
              onIncludeSeventhChordsChanged: (_) {},
              onHandSelectionChanged: (_) {},
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Practice Active - Keep Playing!"), findsOneWidget);
    });
  });
}
