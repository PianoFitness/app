import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/state/exercise_strategy_factory.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategies.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("ExerciseStrategyFactory Tests", () {
    test("creates ScalesStrategy for scales mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.scales,
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.right,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<ScalesStrategy>());
    });

    test("creates ArpeggiosStrategy for arpeggios mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.arpeggios,
        musicalNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        handSelection: HandSelection.both,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<ArpeggiosStrategy>());
    });

    test("creates BlockChordsStrategy for blockChords mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.blockChords,
        musicalNote: MusicalNote.c,
        arpeggioType: ArpeggioType.minor,
        handSelection: HandSelection.left,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<BlockChordsStrategy>());
    });

    test("creates ChordsByKeyStrategy for chordsByKey mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByKey,
        key: music.Key.g,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.right,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<ChordsByKeyStrategy>());
    });

    test("creates ChordsByTypeStrategy for chordsByType mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByType,
        chordType: ChordType.major,
        handSelection: HandSelection.right,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<ChordsByTypeStrategy>());
    });

    test("creates ChordProgressionsStrategy for chordProgressions mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.chordProgressions,
        key: music.Key.f,
        chordProgressionId: "I - V",
        handSelection: HandSelection.right,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<ChordProgressionsStrategy>());
    });

    test("creates DominantCadenceStrategy for dominantCadence mode", () {
      const config = ExerciseConfiguration(
        practiceMode: PracticeMode.dominantCadence,
        key: music.Key.d,
        handSelection: HandSelection.right,
      );

      final strategy = ExerciseStrategyFactory.create(config);
      expect(strategy, isA<DominantCadenceStrategy>());
    });
  });
}
