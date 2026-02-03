// Unit tests for PracticeSession auto key progression functionality.
//
// Tests the automatic key progression feature that advances through keys
// following the circle of fifths when exercises are completed.

import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";

import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/shared/models/practice_session.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/circle_of_fifths.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("PracticeSession Auto Key Progression Tests", () {
    late PracticeSession practiceSession;
    List<NotePosition> highlightedNotes = [];
    int exerciseCompletionCount = 0;

    setUp(() {
      highlightedNotes = [];
      exerciseCompletionCount = 0;

      practiceSession = PracticeSession(
        onExerciseCompleted: () {
          exerciseCompletionCount++;
        },
        onHighlightedNotesChanged: (notes) {
          highlightedNotes = notes;
        },
      );
    });

    group("Auto progression disabled by default", () {
      test("autoProgressKeys is false by default", () {
        expect(practiceSession.autoProgressKeys, isFalse);
      });

      test("completing exercise does not change key when disabled", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);
        expect(practiceSession.selectedKey, equals(music.Key.c));

        // Complete exercise with auto-progression disabled
        practiceSession.triggerCompletionForTesting();

        // Key should remain unchanged
        expect(practiceSession.selectedKey, equals(music.Key.c));
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
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);

        // Complete first exercise - should progress to G
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));

        // Complete second exercise - should progress to D
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.d));

        // Complete third exercise - should progress to A
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.a));
      });

      test("chords by key mode progresses through circle of fifths", () {
        practiceSession.setPracticeMode(PracticeMode.chordsByKey);
        practiceSession.setSelectedKey(music.Key.e);

        // Complete exercise - should progress from E to B
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.b));

        // Complete exercise - should progress from B to F♯
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.fSharp));
      });

      test("chord progressions mode progresses through circle of fifths", () {
        practiceSession.setPracticeMode(PracticeMode.chordProgressions);
        practiceSession.setSelectedKey(music.Key.f);

        // Complete exercise - should progress from F to C (wraps around)
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.c));

        // Complete exercise - should progress from C to G
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));
      });

      test("arpeggios mode progresses root note through circle of fifths", () {
        practiceSession.setPracticeMode(PracticeMode.arpeggios);
        practiceSession.setSelectedKey(music.Key.c);
        practiceSession.setSelectedRootNote(MusicalNote.c);
        practiceSession.setSelectedArpeggioType(ArpeggioType.major);

        // Verify initial state
        expect(practiceSession.selectedKey, equals(music.Key.c));
        expect(practiceSession.selectedRootNote, equals(MusicalNote.c));

        // Complete exercise - should progress from C to G
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));
        expect(practiceSession.selectedRootNote, equals(MusicalNote.g));

        // Complete exercise - should progress from G to D
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.d));
        expect(practiceSession.selectedRootNote, equals(MusicalNote.d));

        // Complete exercise - should progress from D to A
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.a));
        expect(practiceSession.selectedRootNote, equals(MusicalNote.a));
      });

      test("wraps around from F to C", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.f);

        // Complete exercise - should wrap around to C
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.c));
      });

      test("progresses through all 12 keys and returns to start", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);

        final keysVisited = <music.Key>[music.Key.c];

        // Complete 12 exercises to cycle through all keys
        for (int i = 0; i < 12; i++) {
          practiceSession.triggerCompletionForTesting();
          keysVisited.add(practiceSession.selectedKey);
        }

        // Should have visited 13 keys total (start + 12 progressions)
        expect(keysVisited.length, equals(13));

        // Should end where we started (back to C)
        expect(keysVisited.last, equals(music.Key.c));

        // Should match circle of fifths order
        expect(
          keysVisited.sublist(0, 12),
          equals(CircleOfFifths.circleOfFifths),
        );
      });

      test("triggers onExerciseCompleted callback on each completion", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);

        expect(exerciseCompletionCount, equals(0));

        practiceSession.triggerCompletionForTesting();
        expect(exerciseCompletionCount, equals(1));

        practiceSession.triggerCompletionForTesting();
        expect(exerciseCompletionCount, equals(2));

        practiceSession.triggerCompletionForTesting();
        expect(exerciseCompletionCount, equals(3));
      });
    });

    group("Manual key change with auto progression enabled", () {
      setUp(() {
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setPracticeMode(PracticeMode.scales);
      });

      test("progression starts from manually selected key", () {
        // Start at C
        practiceSession.setSelectedKey(music.Key.c);
        expect(practiceSession.selectedKey, equals(music.Key.c));

        // Manually change to E
        practiceSession.setSelectedKey(music.Key.e);
        expect(practiceSession.selectedKey, equals(music.Key.e));

        // Complete exercise - should progress from E to B
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.b));

        // Complete exercise - should progress from B to F♯
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.fSharp));
      });

      test("can jump to any key mid-progression", () {
        practiceSession.setSelectedKey(music.Key.c);

        // Progress a few times
        practiceSession.triggerCompletionForTesting(); // C → G
        practiceSession.triggerCompletionForTesting(); // G → D
        expect(practiceSession.selectedKey, equals(music.Key.d));

        // Manually jump to A♯
        practiceSession.setSelectedKey(music.Key.aSharp);
        expect(practiceSession.selectedKey, equals(music.Key.aSharp));

        // Progression should continue from A♯
        practiceSession.triggerCompletionForTesting(); // A♯ → F
        expect(practiceSession.selectedKey, equals(music.Key.f));

        practiceSession.triggerCompletionForTesting(); // F → C
        expect(practiceSession.selectedKey, equals(music.Key.c));
      });
    });

    group("Toggling auto progression mid-session", () {
      test("disabling stops progression", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);
        practiceSession.setAutoKeyProgression(true);

        // Complete with auto-progression enabled
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));

        // Disable auto-progression
        practiceSession.setAutoKeyProgression(false);

        // Complete exercise - key should not change
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));
      });

      test("re-enabling resumes progression from current key", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setSelectedKey(music.Key.c);
        practiceSession.setAutoKeyProgression(true);

        // Progress to D
        practiceSession.triggerCompletionForTesting(); // C → G
        practiceSession.triggerCompletionForTesting(); // G → D
        expect(practiceSession.selectedKey, equals(music.Key.d));

        // Disable and complete
        practiceSession.setAutoKeyProgression(false);
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.d));

        // Re-enable and complete - should resume from D
        practiceSession.setAutoKeyProgression(true);
        practiceSession.triggerCompletionForTesting(); // D → A
        expect(practiceSession.selectedKey, equals(music.Key.a));
      });
    });

    group("Auto progression with different scale types", () {
      setUp(() {
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setPracticeMode(PracticeMode.scales);
      });

      test("major scales progress through all keys", () {
        practiceSession.setSelectedKey(music.Key.c);
        practiceSession.setSelectedScaleType(music.ScaleType.major);

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));
        expect(
          practiceSession.selectedScaleType,
          equals(music.ScaleType.major),
        );
      });

      test("minor scales progress through all keys", () {
        practiceSession.setSelectedKey(music.Key.a);
        practiceSession.setSelectedScaleType(music.ScaleType.minor);

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.e));
        expect(
          practiceSession.selectedScaleType,
          equals(music.ScaleType.minor),
        );
      });

      test("modal scales progress through all keys", () {
        practiceSession.setSelectedKey(music.Key.d);
        practiceSession.setSelectedScaleType(music.ScaleType.dorian);

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.a));
        expect(
          practiceSession.selectedScaleType,
          equals(music.ScaleType.dorian),
        );
      });

      test("arpeggios preserve type while progressing through keys", () {
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setPracticeMode(PracticeMode.arpeggios);
        practiceSession.setSelectedKey(music.Key.c);
        practiceSession.setSelectedRootNote(MusicalNote.c);
        practiceSession.setSelectedArpeggioType(ArpeggioType.minor);

        // Progress through multiple keys
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedRootNote, equals(MusicalNote.g));
        expect(
          practiceSession.selectedArpeggioType,
          equals(ArpeggioType.minor),
        );

        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedRootNote, equals(MusicalNote.d));
        expect(
          practiceSession.selectedArpeggioType,
          equals(ArpeggioType.minor),
        );
      });
    });

    group("Edge cases and state management", () {
      test("practiceActive is reset after progression", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setSelectedKey(music.Key.c);

        // Start practice
        practiceSession.startPractice();
        expect(practiceSession.practiceActive, isTrue);

        // Complete exercise
        practiceSession.triggerCompletionForTesting();

        // Should not be active after completion
        expect(practiceSession.practiceActive, isFalse);
      });

      test("currentExercise is regenerated after progression", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setSelectedKey(music.Key.c);

        final exerciseBefore = practiceSession.currentExercise;
        expect(exerciseBefore, isNotNull);

        // Complete and progress to next key
        practiceSession.triggerCompletionForTesting();
        expect(practiceSession.selectedKey, equals(music.Key.g));

        final exerciseAfter = practiceSession.currentExercise;
        expect(exerciseAfter, isNotNull);

        // Exercise should be different (new key)
        expect(exerciseAfter, isNot(same(exerciseBefore)));
      });

      test("highlighted notes are updated after progression", () {
        practiceSession.setPracticeMode(PracticeMode.scales);
        practiceSession.setAutoKeyProgression(true);
        practiceSession.setSelectedKey(music.Key.c);

        // Start practice to get initial highlights
        practiceSession.startPractice();
        final highlightsBefore = List<NotePosition>.from(highlightedNotes);
        expect(highlightsBefore, isNotEmpty);

        // Complete and progress
        practiceSession.triggerCompletionForTesting();

        // Start new practice after progression
        practiceSession.startPractice();
        final highlightsAfter = List<NotePosition>.from(highlightedNotes);
        expect(highlightsAfter, isNotEmpty);

        // Highlights should be different (different key)
        expect(highlightsAfter, isNot(equals(highlightsBefore)));
      });
    });
  });
}
