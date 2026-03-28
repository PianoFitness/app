import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;

void main() {
  const testId = "test-entry-id";
  const testProfileId = "test-profile-id";
  final testCompletedAt = DateTime(2025, 6, 15, 10, 30);

  group("ExerciseHistoryEntry.fromConfiguration", () {
    group("Identity fields", () {
      test("should assign id, profileId, and completedAt correctly", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.id, equals(testId));
        expect(entry.profileId, equals(testProfileId));
        expect(entry.completedAt, equals(testCompletedAt));
      });
    });

    group("Scales mode", () {
      test("should copy scales configuration fields correctly", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.right,
          key: music.Key.d,
          scaleType: music.ScaleType.minor,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.practiceMode, equals(PracticeMode.scales));
        expect(entry.handSelection, equals(HandSelection.right));
        expect(entry.musicalKey, equals(music.Key.d));
        expect(entry.scaleType, equals(music.ScaleType.minor));
        expect(entry.chordType, isNull);
        expect(entry.includeInversions, isFalse);
        expect(entry.includeSeventhChords, isFalse);
        expect(entry.musicalNote, isNull);
        expect(entry.arpeggioType, isNull);
        expect(entry.chordProgressionId, isNull);
      });
    });

    group("ChordsByKey mode", () {
      test("should copy chordsByKey configuration fields correctly", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.left,
          key: music.Key.f,
          scaleType: music.ScaleType.major,
          includeSeventhChords: true,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.practiceMode, equals(PracticeMode.chordsByKey));
        expect(entry.handSelection, equals(HandSelection.left));
        expect(entry.musicalKey, equals(music.Key.f));
        expect(entry.scaleType, equals(music.ScaleType.major));
        expect(entry.includeSeventhChords, isTrue);
        expect(entry.chordType, isNull);
        expect(entry.musicalNote, isNull);
      });
    });

    group("ChordsByType mode", () {
      test("should copy chordsByType configuration fields correctly", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.diminished,
          includeInversions: true,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.practiceMode, equals(PracticeMode.chordsByType));
        expect(entry.handSelection, equals(HandSelection.both));
        expect(entry.chordType, equals(ChordType.diminished));
        expect(entry.includeInversions, isTrue);
        expect(entry.musicalKey, isNull);
        expect(entry.scaleType, isNull);
      });
    });

    group("Arpeggios mode", () {
      test("should copy arpeggios configuration fields correctly", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.right,
          musicalNote: MusicalNote.g,
          arpeggioType: ArpeggioType.minor,
          arpeggioOctaves: ArpeggioOctaves.two,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.practiceMode, equals(PracticeMode.arpeggios));
        expect(entry.handSelection, equals(HandSelection.right));
        expect(entry.musicalNote, equals(MusicalNote.g));
        expect(entry.arpeggioType, equals(ArpeggioType.minor));
        expect(entry.arpeggioOctaves, equals(ArpeggioOctaves.two));
        expect(entry.musicalKey, isNull);
        expect(entry.chordType, isNull);
      });
    });

    group("ChordProgressions mode", () {
      test("should copy chordProgressions configuration fields correctly", () {
        const progressionId = "I-IV-V-I";
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordProgressions,
          handSelection: HandSelection.both,
          key: music.Key.g,
          chordProgressionId: progressionId,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.practiceMode, equals(PracticeMode.chordProgressions));
        expect(entry.musicalKey, equals(music.Key.g));
        expect(entry.chordProgressionId, equals(progressionId));
      });
    });

    group("Default values", () {
      test("includeInversions defaults to false when not set", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
        );

        final entry = ExerciseHistoryEntry.fromConfiguration(
          id: testId,
          profileId: testProfileId,
          completedAt: testCompletedAt,
          config: config,
        );

        expect(entry.includeInversions, isFalse);
        expect(entry.includeSeventhChords, isFalse);
      });
    });
  });
}
