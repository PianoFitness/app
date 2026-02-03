import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "../../shared/midi_mocks.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("PracticePageViewModel Tests", () {
    late PracticePageViewModel viewModel;
    var exerciseCompletedCalled = false;
    var receivedHighlightedNotes = <NotePosition>[];

    setUp(() {
      viewModel = PracticePageViewModel(initialChannel: 3);
      exerciseCompletedCalled = false;
      receivedHighlightedNotes = [];

      // Note: Practice page now uses local MIDI state, so we don't set external state
      viewModel.initializePracticeSession(
        onExerciseCompleted: () {
          exerciseCompletedCalled = true;
        },
        onHighlightedNotesChanged: (notes) {
          receivedHighlightedNotes = notes;
        },
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test("should initialize with correct MIDI channel", () {
      expect(viewModel.midiChannel, equals(3));
      expect(viewModel.localMidiState.selectedChannel, equals(3));
    });

    test("should initialize practice session correctly", () {
      expect(viewModel.practiceSession, isNotNull);
      expect(
        viewModel.practiceSession!.practiceMode,
        equals(PracticeMode.scales),
      );
      expect(viewModel.practiceSession!.practiceActive, isFalse);
    });

    test("should handle MIDI data and update state for note on events", () {
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      viewModel.handleMidiData(midiData);

      expect(viewModel.localMidiState.activeNotes.contains(60), isTrue);
      expect(
        viewModel.localMidiState.lastNote,
        "Note ON: 60 (Ch: 1, Vel: 100)",
      );
      expect(viewModel.localMidiState.hasRecentActivity, isTrue);
    });

    test("should handle MIDI data and update state for note off events", () {
      // First add a note to local MIDI state
      viewModel.localMidiState.noteOn(60, 100, 1);
      expect(viewModel.localMidiState.activeNotes.contains(60), isTrue);

      final midiData = Uint8List.fromList([0x80, 60, 0]);

      viewModel.handleMidiData(midiData);

      expect(viewModel.localMidiState.activeNotes.contains(60), isFalse);
      expect(viewModel.localMidiState.lastNote, "Note OFF: 60 (Ch: 1)");
    });

    test("should start and reset practice sessions", () {
      expect(viewModel.practiceSession!.practiceActive, isFalse);

      viewModel.startPractice();
      expect(viewModel.practiceSession!.practiceActive, isTrue);

      viewModel.resetPractice();
      expect(viewModel.practiceSession!.practiceActive, isFalse);
    });

    test("should change practice mode and notify listeners", () {
      var notificationReceived = false;
      viewModel
        ..addListener(() {
          notificationReceived = true;
        })
        ..setPracticeMode(PracticeMode.chordsByKey);

      expect(
        viewModel.practiceSession!.practiceMode,
        equals(PracticeMode.chordsByKey),
      );
      expect(notificationReceived, isTrue);
    });

    test("should change selected key and notify listeners", () {
      var notificationReceived = false;
      viewModel
        ..addListener(() {
          notificationReceived = true;
        })
        ..setSelectedKey(music.Key.d);

      expect(viewModel.practiceSession!.selectedKey, equals(music.Key.d));
      expect(notificationReceived, isTrue);
    });

    test("should change selected scale type and notify listeners", () {
      var notificationReceived = false;
      viewModel
        ..addListener(() {
          notificationReceived = true;
        })
        ..setSelectedScaleType(music.ScaleType.minor);

      expect(
        viewModel.practiceSession!.selectedScaleType,
        equals(music.ScaleType.minor),
      );
      expect(notificationReceived, isTrue);
    });

    test("should change selected arpeggio type and notify listeners", () {
      var notificationReceived = false;
      viewModel
        ..addListener(() {
          notificationReceived = true;
        })
        ..setSelectedArpeggioType(ArpeggioType.minor);

      expect(
        viewModel.practiceSession!.selectedArpeggioType,
        equals(ArpeggioType.minor),
      );
      expect(notificationReceived, isTrue);
    });

    test("should calculate appropriate highlighted notes for display", () {
      // Test when ViewModel has highlighted notes
      final testNotes = [
        NotePosition(note: Note.C),
        NotePosition(note: Note.E),
      ];
      receivedHighlightedNotes = testNotes;
      viewModel.practiceSession!.onHighlightedNotesChanged(testNotes);

      final result = viewModel.getDisplayHighlightedNotes();
      expect(result, equals(testNotes));

      // Test when ViewModel has no highlighted notes, falls back to local MidiState
      viewModel.practiceSession!.onHighlightedNotesChanged([]);
      viewModel.localMidiState.noteOn(60, 100, 1);

      final fallbackResult = viewModel.getDisplayHighlightedNotes();
      expect(
        fallbackResult,
        equals(viewModel.localMidiState.highlightedNotePositions),
      );
    });

    test("should calculate practice range correctly", () {
      final range = viewModel.calculatePracticeRange();

      expect(range, isNotNull);
      expect(range, isA<NoteRange>());
    });

    test("should handle virtual note playing without throwing", () async {
      const testNote = 60;

      // This test verifies the method handles missing practice session gracefully
      final uninitializedViewModel = PracticePageViewModel();

      // Should not crash when no practice session is initialized
      await uninitializedViewModel.playVirtualNote(testNote, mounted: false);

      uninitializedViewModel.dispose();
    });

    test("should handle cases with no practice session initialized", () {
      final uninitializedViewModel = PracticePageViewModel();
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      // Should not crash when no practice session is set
      expect(
        () => uninitializedViewModel.handleMidiData(midiData),
        returnsNormally,
      );

      uninitializedViewModel.dispose();
    });

    test("should provide access to MIDI command instance", () {
      expect(viewModel.midiCommand, isNotNull);
    });

    group("Practice Session Integration", () {
      test("should trigger exercise completed callback", () {
        // This would be triggered by the practice session internally
        // when an exercise is completed
        expect(exerciseCompletedCalled, isFalse);

        // Simulate exercise completion by calling the callback directly
        viewModel.practiceSession!.onExerciseCompleted();

        expect(exerciseCompletedCalled, isTrue);
      });

      test("should update highlighted notes through callback", () {
        // Reset to ensure clean state
        receivedHighlightedNotes.clear();

        final testNotes = [
          NotePosition(note: Note.C),
          NotePosition(note: Note.E),
          NotePosition(note: Note.G),
        ];

        // Ensure we start with empty state
        expect(receivedHighlightedNotes, isEmpty);

        // Simulate highlighted notes change
        viewModel.practiceSession!.onHighlightedNotesChanged(testNotes);

        expect(receivedHighlightedNotes, equals(testNotes));
        expect(viewModel.highlightedNotes, equals(testNotes));

        // Test clearing notes
        viewModel.practiceSession!.onHighlightedNotesChanged([]);
        expect(receivedHighlightedNotes, isEmpty);
        expect(viewModel.highlightedNotes, isEmpty);
      });
    });

    group("MIDI Data Processing Edge Cases", () {
      test("should handle control change messages", () {
        final midiData = Uint8List.fromList([0xB0, 7, 100]);

        viewModel.handleMidiData(midiData);

        expect(
          viewModel.localMidiState.lastNote,
          "CC: Controller 7 = 100 (Ch: 1)",
        );
      });

      test("should handle program change messages", () {
        final midiData = Uint8List.fromList([0xC0, 42]);

        viewModel.handleMidiData(midiData);

        expect(viewModel.localMidiState.lastNote, "Program Change: 42 (Ch: 1)");
      });

      test("should handle pitch bend messages", () {
        final midiData = Uint8List.fromList([0xE0, 0x00, 0x60]);

        viewModel.handleMidiData(midiData);

        expect(
          viewModel.localMidiState.lastNote.contains("Pitch Bend"),
          isTrue,
        );
      });

      test("should filter out clock and active sense messages", () {
        final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
        final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

        viewModel.localMidiState.setLastNote("Previous message");

        viewModel.handleMidiData(clockMessage);
        expect(viewModel.localMidiState.lastNote, equals("Previous message"));

        viewModel.handleMidiData(activeSenseMessage);
        expect(viewModel.localMidiState.lastNote, equals("Previous message"));
      });
    });

    group("Practice Settings Management", () {
      test("should handle all practice mode changes", () {
        final modes = [
          PracticeMode.scales,
          PracticeMode.chordsByKey,
          PracticeMode.chordsByType,
          PracticeMode.arpeggios,
        ];

        for (final mode in modes) {
          viewModel.setPracticeMode(mode);
          expect(viewModel.practiceSession!.practiceMode, equals(mode));
        }
      });

      test("should handle all key changes", () {
        final keys = [music.Key.c, music.Key.d, music.Key.e, music.Key.f];

        for (final key in keys) {
          viewModel.setSelectedKey(key);
          expect(viewModel.practiceSession!.selectedKey, equals(key));
        }
      });

      test("should handle all scale type changes", () {
        final scaleTypes = [
          music.ScaleType.major,
          music.ScaleType.minor,
          music.ScaleType.dorian,
          music.ScaleType.mixolydian,
        ];

        for (final scaleType in scaleTypes) {
          viewModel.setSelectedScaleType(scaleType);
          expect(
            viewModel.practiceSession!.selectedScaleType,
            equals(scaleType),
          );
        }
      });

      test(
        "should handle setSelectedChordType and reset practice sequence",
        () {
          // Switch to chords by type mode first
          viewModel.setPracticeMode(PracticeMode.chordsByType);

          // Start a practice session to have an active sequence
          viewModel.startPractice();
          expect(viewModel.practiceSession!.practiceActive, isTrue);

          final initialExercise = viewModel.practiceSession!.currentExercise;
          expect(initialExercise, isNotNull);
          expect(initialExercise!.isNotEmpty, isTrue);

          var notificationReceived = false;
          viewModel.addListener(() {
            notificationReceived = true;
          });

          // Change chord type - should reset sequence and notify
          viewModel.setSelectedChordType(ChordType.diminished);

          expect(
            viewModel.practiceSession!.selectedChordType,
            equals(ChordType.diminished),
          );
          expect(notificationReceived, isTrue);

          // Verify practice sequence resets after changing the type
          expect(viewModel.practiceSession!.practiceActive, isFalse);

          // Verify sequence content updates accordingly
          final newExercise = viewModel.practiceSession!.currentExercise;
          expect(newExercise, isNot(equals(initialExercise)));
          expect(newExercise, isNotNull);
          expect(newExercise!.isNotEmpty, isTrue);
        },
      );

      test("should handle setIncludeInversions and update sequence length", () {
        // Switch to chords by type mode
        viewModel.setPracticeMode(PracticeMode.chordsByType);

        // Start with inversions disabled
        viewModel.setIncludeInversions(false);
        expect(viewModel.practiceSession!.includeInversions, isFalse);

        viewModel.startPractice();
        final rootOnlySequenceLength =
            viewModel.practiceSession!.currentExercise!.length;
        expect(rootOnlySequenceLength, greaterThan(0));

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        // Enable inversions - should change total sequence length
        viewModel.setIncludeInversions(true);

        expect(viewModel.practiceSession!.includeInversions, isTrue);
        expect(notificationReceived, isTrue);

        // Verify practice resets
        expect(viewModel.practiceSession!.practiceActive, isFalse);

        // Start new practice with inversions
        viewModel.startPractice();
        final withInversionsSequenceLength =
            viewModel.practiceSession!.currentExercise!.length;

        // With inversions enabled, sequence should be longer
        expect(
          withInversionsSequenceLength,
          greaterThan(rootOnlySequenceLength),
        );
      });

      test(
        "should update highlighted notes when chord type or inversions change",
        () {
          // Switch to chords by type mode
          viewModel.setPracticeMode(PracticeMode.chordsByType);
          viewModel.setSelectedChordType(ChordType.major);

          // Reset highlighted notes tracking
          receivedHighlightedNotes.clear();

          viewModel.startPractice();
          final initialHighlightedNotes = List<NotePosition>.from(
            receivedHighlightedNotes,
          );
          expect(initialHighlightedNotes.isNotEmpty, isTrue);

          // Change chord type
          viewModel.setSelectedChordType(ChordType.minor);
          viewModel.startPractice();

          // Verify highlighted notes changed
          expect(
            receivedHighlightedNotes,
            isNot(equals(initialHighlightedNotes)),
          );
          expect(receivedHighlightedNotes.isNotEmpty, isTrue);

          // Test inversions setting
          receivedHighlightedNotes.clear();
          viewModel.setIncludeInversions(false);
          viewModel.startPractice();

          final rootOnlyNotes = List<NotePosition>.from(
            receivedHighlightedNotes,
          );
          expect(rootOnlyNotes.isNotEmpty, isTrue);

          receivedHighlightedNotes.clear();
          viewModel.setIncludeInversions(true);
          viewModel.startPractice();

          // Notes should be different since inversions affect chord sequence
          expect(receivedHighlightedNotes.isNotEmpty, isTrue);
        },
      );

      test("should handle chord type changes and reset practice sequence", () {
        // Switch to chords by type mode first
        viewModel.setPracticeMode(PracticeMode.chordsByType);

        // Start a practice session to have an active sequence
        viewModel.startPractice();
        expect(viewModel.practiceSession!.practiceActive, isTrue);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        // Test changing chord type - should reset sequence and notify
        viewModel.setSelectedChordType(ChordType.minor);

        expect(
          viewModel.practiceSession!.selectedChordType,
          equals(ChordType.minor),
        );
        expect(notificationReceived, isTrue);

        // Verify practice sequence resets after changing chord type
        expect(viewModel.practiceSession!.practiceActive, isFalse);
      });

      test("should handle chord type changes and update sequence content", () {
        // Switch to chords by type mode
        viewModel.setPracticeMode(PracticeMode.chordsByType);

        // Test all chord types
        final chordTypes = [
          ChordType.major,
          ChordType.minor,
          ChordType.diminished,
          ChordType.augmented,
        ];

        for (final chordType in chordTypes) {
          viewModel.setSelectedChordType(chordType);
          expect(
            viewModel.practiceSession!.selectedChordType,
            equals(chordType),
          );

          // Start practice to generate sequence
          viewModel.startPractice();

          // Verify that highlighted notes change based on chord type
          // (This would be validated through the practice session's sequence generation)
          expect(viewModel.practiceSession!.currentExercise, isNotNull);
          expect(
            viewModel.practiceSession!.currentExercise!.isNotEmpty,
            isTrue,
          );

          // Reset for next iteration
          viewModel.resetPractice();
        }
      });

      test("should handle include inversions setting changes", () {
        // Switch to chords by type mode first
        viewModel.setPracticeMode(PracticeMode.chordsByType);

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        // Test enabling inversions
        viewModel.setIncludeInversions(true);

        expect(viewModel.practiceSession!.includeInversions, isTrue);
        expect(notificationReceived, isTrue);

        // Test disabling inversions
        notificationReceived = false;
        viewModel.setIncludeInversions(false);

        expect(viewModel.practiceSession!.includeInversions, isFalse);
        expect(notificationReceived, isTrue);
      });

      test("should change sequence length when inversions setting changes", () {
        // Switch to chords by type mode
        viewModel.setPracticeMode(PracticeMode.chordsByType);

        // Start with inversions disabled
        viewModel.setIncludeInversions(false);
        viewModel.startPractice();

        final rootOnlySequenceLength =
            viewModel.practiceSession!.currentExercise!.length;
        expect(rootOnlySequenceLength, greaterThan(0));

        // Reset and enable inversions
        viewModel.resetPractice();
        viewModel.setIncludeInversions(true);
        viewModel.startPractice();

        final withInversionsSequenceLength =
            viewModel.practiceSession!.currentExercise!.length;

        // With inversions enabled, sequence should be longer (root + first + second inversions)
        expect(
          withInversionsSequenceLength,
          greaterThan(rootOnlySequenceLength),
        );
        // Avoid strict equality to implementation-specific multiplier
      });

      test(
        "should update chord notes content when inversions setting changes",
        () {
          // Switch to chords by type mode with a specific chord type
          viewModel.setPracticeMode(PracticeMode.chordsByType);
          viewModel.setSelectedChordType(ChordType.major);

          // Test with inversions disabled (root position only)
          viewModel.setIncludeInversions(false);
          viewModel.startPractice();

          final rootOnlyExercise = viewModel.practiceSession!.currentExercise!;
          expect(rootOnlyExercise.isNotEmpty, isTrue);
          final rootOnlyLength = rootOnlyExercise.length;

          // Reset and enable inversions
          viewModel.resetPractice();
          viewModel.setIncludeInversions(true);
          viewModel.startPractice();

          final withInversionsExercise =
              viewModel.practiceSession!.currentExercise!;
          expect(withInversionsExercise.isNotEmpty, isTrue);

          // With inversions, sequence should contain additional chord positions
          // The sequence should include different chord voicings/inversions
          expect(withInversionsExercise.length, greaterThan(rootOnlyLength));

          // Note: The actual sequence structure depends on how the practice session
          // generates chord progressions with inversions. We just verify that
          // enabling inversions changes the sequence content and length.
        },
      );
    });
  });
}
