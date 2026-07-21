// Unit tests for PracticeSession auto key progression functionality.
//
// Tests the automatic key progression feature that advances through keys
// following the circle of fifths when exercises are completed.

import "package:flutter_test/flutter_test.dart";

import "package:piano_fitness/application/state/practice_session.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("PracticeSession Auto Key Progression Tests", () {
    late PracticeSession practiceSession;

    setUp(() {
      practiceSession = PracticeSession(
        onExerciseCompleted: (a, b, c) {},
        onHighlightedNotesChanged: (notes) {},
      );
    });

    group("Auto progression disabled by default", () {
      test("autoProgressKeys is false by default", () {
        expect(practiceSession.autoProgressKeys, isFalse);
      });

      test("completing exercise does not change key when disabled", () {
        practiceSession.updateConfiguration(
          practiceSession.config.withMode(PracticeMode.scales),
        );
        practiceSession.updateConfiguration(
          practiceSession.config.copyWith(key: const Field.set(music.Key.c)),
        );
        expect(practiceSession.selectedKey, equals(music.Key.c));

        practiceSession.triggerCompletionForTesting();

        expect(practiceSession.selectedKey, equals(music.Key.c));
      });
    });

    group("Getters and Helper Tests", () {
      test("getNotesForRangeCalculation returns notes from exercise", () {
        practiceSession.updateConfiguration(
          const ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.right,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          ),
        );
        final notes = practiceSession.getNotesForRangeCalculation();
        expect(notes, isNotEmpty);
      });

      test("getters reflect exercise configuration values", () {
        practiceSession.updateConfiguration(
          ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.g,
            chordProgressionId: "I - V",
            musicalNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            chordType: ChordType.minor,
            includeInversions: true,
            includeSeventhChords: true,
          ),
        );

        expect(practiceSession.selectedChordProgression, isNotNull);
        expect(practiceSession.selectedRootNote, equals(MusicalNote.c));
        expect(practiceSession.selectedArpeggioType, equals(ArpeggioType.major));
        expect(practiceSession.selectedChordType, equals(ChordType.minor));
        expect(practiceSession.includeInversions, isTrue);
        expect(practiceSession.includeSeventhChords, isTrue);
      });
    });

    group("Auto progression enabled", () {
      test("setAutoKeyProgression enables auto progression", () {
        practiceSession.setAutoKeyProgression(true);
        expect(practiceSession.autoProgressKeys, isTrue);
      });

      test("setAutoKeyProgression disables auto progression", () {
        practiceSession.setAutoKeyProgression(true);
        expect(practiceSession.autoProgressKeys, isTrue);

        practiceSession.setAutoKeyProgression(false);
        expect(practiceSession.autoProgressKeys, isFalse);
      });
    });

    group("Key progression on exercise completion", () {
      setUp(() {
        practiceSession.setAutoKeyProgression(true);
      });

      test("scales mode progresses through circle of fifths", () {
        practiceSession.updateConfiguration(
          practiceSession.config.withMode(PracticeMode.scales),
        );
        practiceSession.updateConfiguration(
          practiceSession.config.copyWith(key: const Field.set(music.Key.c)),
        );

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.d));

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.a));
      });
    });
  });
}
