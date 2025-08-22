import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

void main() {
  group("ChordByType - Chord Planing", () {
    test("should generate chord planing sequence across all 12 keys", () {
      final majorChordExercise = ChordByTypeDefinitions.getMajorChordExercise(
        includeInversions: false,
      );

      expect(majorChordExercise.type, equals(ChordType.major));
      expect(majorChordExercise.includeInversions, isFalse);
      expect(majorChordExercise.name, contains("Major Chords"));
      expect(majorChordExercise.name, contains("All 12 Keys"));

      final chords = majorChordExercise.generateChordSequence();

      // Should have 12 chords for all chromatic keys, no inversions
      expect(chords.length, equals(12));

      // All chords should be major type
      for (final chord in chords) {
        expect(chord.type, equals(ChordType.major));
        expect(chord.inversion, equals(ChordInversion.root));
      }

      // Should contain all 12 chromatic roots
      final uniqueRootNotes = chords.map((chord) => chord.rootNote).toSet();
      expect(uniqueRootNotes.length, equals(12));
      expect(uniqueRootNotes, contains(MusicalNote.c));
      expect(uniqueRootNotes, contains(MusicalNote.cSharp));
      expect(uniqueRootNotes, contains(MusicalNote.fSharp));
      expect(uniqueRootNotes, contains(MusicalNote.b));
    });

    test("should generate chord planing with inversions for all 12 keys", () {
      final minorChordExercise = ChordByTypeDefinitions.getMinorChordExercise();

      expect(minorChordExercise.type, equals(ChordType.minor));
      expect(minorChordExercise.includeInversions, isTrue);
      expect(minorChordExercise.name, contains("All 12 Keys"));

      final chords = minorChordExercise.generateChordSequence();

      // Should have 36 chords (12 root notes × 3 positions each)
      expect(chords.length, equals(36));

      // First three chords should be C minor in different inversions
      expect(chords[0].rootNote, equals(MusicalNote.c));
      expect(chords[0].type, equals(ChordType.minor));
      expect(chords[0].inversion, equals(ChordInversion.root));
      expect(chords[1].rootNote, equals(MusicalNote.c));
      expect(chords[1].type, equals(ChordType.minor));
      expect(chords[1].inversion, equals(ChordInversion.first));
      expect(chords[2].rootNote, equals(MusicalNote.c));
      expect(chords[2].type, equals(ChordType.minor));
      expect(chords[2].inversion, equals(ChordInversion.second));

      // Should include all 12 chromatic root notes
      final uniqueRootNotes = chords.map((chord) => chord.rootNote).toSet();
      expect(uniqueRootNotes.length, equals(12));
    });

    test("should demonstrate chord planing concept with augmented chords", () {
      final augmentedChordExercise =
          ChordByTypeDefinitions.getAugmentedChordExercise(
            includeInversions: false,
          );

      final chords = augmentedChordExercise.generateChordSequence();

      // Should have 12 chords for all chromatic notes
      expect(chords.length, equals(12));

      // Should include both natural and sharp/flat notes
      final rootNotes = chords.map((chord) => chord.rootNote).toSet();
      expect(rootNotes, contains(MusicalNote.c));
      expect(rootNotes, contains(MusicalNote.cSharp));
      expect(rootNotes, contains(MusicalNote.fSharp));
    });

    test("should generate MIDI sequence for chord planing practice", () {
      final majorChordExercise = ChordByTypeDefinitions.getMajorChordExercise(
        includeInversions: false,
      );

      final midiSequence = majorChordExercise.getMidiSequence(4);

      // Should have MIDI notes for all chords in the planing sequence
      expect(midiSequence, isNotEmpty);

      // 12 chromatic chords × 3 notes each (major triads)
      expect(midiSequence.length, equals(36));

      // First three notes should be C major chord in octave 4
      expect(midiSequence[0], equals(60)); // C4
      expect(midiSequence[1], equals(64)); // E4
      expect(midiSequence[2], equals(67)); // G4

      // Next three should be C# major (61, 65, 68)
      expect(midiSequence[3], equals(61)); // C#4
      expect(midiSequence[4], equals(65)); // F4 (E#)
      expect(midiSequence[5], equals(68)); // G#4
    });
  });

  group("ChordByTypeDefinitions - Factory Methods", () {
    test("should return all basic chord type exercises", () {
      final allExercises =
          ChordByTypeDefinitions.getAllBasicChordTypeExercises();

      expect(allExercises.length, equals(4));

      final types = allExercises.map((ex) => ex.type).toSet();
      expect(types.contains(ChordType.major), isTrue);
      expect(types.contains(ChordType.minor), isTrue);
      expect(types.contains(ChordType.diminished), isTrue);
      expect(types.contains(ChordType.augmented), isTrue);
    });

    test("should provide correct display names", () {
      expect(
        ChordByTypeDefinitions.getChordTypeDisplayName(ChordType.major),
        equals("Major Chords"),
      );
      expect(
        ChordByTypeDefinitions.getChordTypeDisplayName(ChordType.minor),
        equals("Minor Chords"),
      );
      expect(
        ChordByTypeDefinitions.getChordTypeDisplayName(ChordType.diminished),
        equals("Diminished Chords"),
      );
      expect(
        ChordByTypeDefinitions.getChordTypeDisplayName(ChordType.augmented),
        equals("Augmented Chords"),
      );
    });

    test(
      "should create different chord planing exercises based on inversions",
      () {
        final basicMajor = ChordByTypeDefinitions.getMajorChordExercise(
          includeInversions: false,
        );

        final advancedMajor = ChordByTypeDefinitions.getMajorChordExercise();

        expect(basicMajor.includeInversions, isFalse);
        expect(advancedMajor.includeInversions, isTrue);

        // Both should use all 12 keys for complete chord planing
        expect(basicMajor.rootNotes.length, equals(12));
        expect(advancedMajor.rootNotes.length, equals(12));

        expect(basicMajor.name, contains("All 12 Keys"));
        expect(advancedMajor.name, contains("All 12 Keys"));

        // Basic should have 12 chords (root position only)
        expect(basicMajor.generateChordSequence().length, equals(12));

        // Advanced should have 36 chords (12 keys × 3 inversions each)
        expect(advancedMajor.generateChordSequence().length, equals(36));
      },
    );
  });

  group("ChordByType sequence size invariants", () {
    test(
      "generateChordSequence count equals rootNotes.length * (includeInversions ? 3 : 1)",
      () {
        final withInversions = ChordByTypeDefinitions.getChordTypeExercise(
          ChordType.minor,
        );
        final withoutInversions = ChordByTypeDefinitions.getChordTypeExercise(
          ChordType.minor,
          includeInversions: false,
        );

        final chordsWithInversions = withInversions.generateChordSequence();
        final chordsWithoutInversions = withoutInversions
            .generateChordSequence();

        // With inversions: 12 keys * 3 positions each = 36
        expect(
          chordsWithInversions.length,
          equals(withInversions.rootNotes.length * 3),
        );
        expect(chordsWithInversions.length, equals(36));

        // Without inversions: 12 keys * 1 position each = 12
        expect(
          chordsWithoutInversions.length,
          equals(withoutInversions.rootNotes.length * 1),
        );
        expect(chordsWithoutInversions.length, equals(12));
      },
    );

    test(
      "getMidiSequence length equals generateChordSequence.length * 3 (triads)",
      () {
        final exercise = ChordByTypeDefinitions.getChordTypeExercise(
          ChordType.minor,
        );
        final chords = exercise.generateChordSequence();
        final midiSequence = exercise.getMidiSequence(4);

        // Each chord has 3 notes (triads), so MIDI sequence should be 3x chord count
        expect(midiSequence.length, equals(chords.length * 3));
        expect(midiSequence.length, equals(36 * 3)); // 108 total notes
      },
    );

    test(
      "display name includes inversion suffix when includeInversions == true",
      () {
        final withInversions = ChordByTypeDefinitions.getChordTypeExercise(
          ChordType.augmented,
        );
        final withoutInversions = ChordByTypeDefinitions.getChordTypeExercise(
          ChordType.augmented,
          includeInversions: false,
        );

        expect(withInversions.name.contains("with inversions"), isTrue);
        expect(withoutInversions.name.contains("with inversions"), isFalse);
      },
    );
  });
}
