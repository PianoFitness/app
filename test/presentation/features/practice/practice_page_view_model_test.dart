import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/presentation/features/practice/practice_page_view_model.dart";
import "../../../shared/midi_mocks.dart";
import "../../../shared/test_helpers/mock_repositories.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("PracticePageViewModel Tests", () {
    late PracticePageViewModel viewModel;
    late MockIMidiRepository mockMidiRepository;
    late MockMidiRepositoryHelper helper;
    late MidiState midiState;
    var exerciseCompletedCalled = false;
    var receivedHighlightedNotes = <NotePosition>[];

    setUp(() {
      // Create mock dependencies
      mockMidiRepository = MockIMidiRepository();
      helper = MockMidiRepositoryHelper(mockMidiRepository);
      midiState = MidiState();

      // Create ViewModel with injected dependencies
      viewModel = PracticePageViewModel(
        midiCoordinator: MidiCoordinator(mockMidiRepository),
        midiRepository: mockMidiRepository,
        midiState: midiState,
        initialChannel: 3,
      );

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
      midiState.dispose();
    });

    test("should initialize with correct MIDI channel", () {
      expect(viewModel.midiChannel, equals(3));
      expect(viewModel.midiState.selectedChannel, equals(3));
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

      helper.simulateMidiData(midiData);

      expect(viewModel.midiState.activeNotes.contains(60), isTrue);
      expect(viewModel.midiState.lastNote, "Note ON: 60 (Ch: 1, Vel: 100)");
      expect(viewModel.midiState.hasRecentActivity, isTrue);
    });

    test("should handle MIDI data and update state for note off events", () {
      // First add a note to local MIDI state
      viewModel.midiState.noteOn(60, 100, 1);
      expect(viewModel.midiState.activeNotes.contains(60), isTrue);

      final midiData = Uint8List.fromList([0x80, 60, 0]);

      helper.simulateMidiData(midiData);

      expect(viewModel.midiState.activeNotes.contains(60), isFalse);
      expect(viewModel.midiState.lastNote, "Note OFF: 60 (Ch: 1)");
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
      viewModel.midiState.noteOn(60, 100, 1);

      final fallbackResult = viewModel.getDisplayHighlightedNotes();
      expect(
        fallbackResult,
        equals(viewModel.midiState.highlightedNotePositions),
      );
    });

    test("should expose notes for range calculation", () {
      final notes = viewModel.notesForRangeCalculation;
      expect(notes, isA<List<int>>());
    });

    test("should play virtual note from NotePosition", () async {
      // C5 = MIDI 72 ((5+1)*12 + 0)
      final position = NotePosition(note: Note.C, octave: 5);
      await viewModel.playVirtualNoteFromPosition(position, mounted: false);
      expect(
        viewModel.midiState.lastNote.contains("Virtual Note ON: 72"),
        isTrue,
      );
    });

    test("should handle virtual note playing without throwing", () async {
      const testNote = 60;

      // This test verifies the method handles missing practice session gracefully
      final uninitRepo = MockIMidiRepository();
      final uninitMidiState = MidiState();
      final uninitializedViewModel = PracticePageViewModel(
        midiCoordinator: MidiCoordinator(uninitRepo),
        midiRepository: uninitRepo,
        midiState: uninitMidiState,
      );

      // Should not crash when no practice session is initialized
      await uninitializedViewModel.playVirtualNote(testNote, mounted: false);

      uninitializedViewModel.dispose();
      uninitMidiState.dispose();
    });

    test("should handle cases with no practice session initialized", () {
      final uninitRepo2 = MockIMidiRepository();
      final uninitHelper2 = MockMidiRepositoryHelper(uninitRepo2);
      final uninitMidiState2 = MidiState();
      final uninitializedViewModel = PracticePageViewModel(
        midiCoordinator: MidiCoordinator(uninitRepo2),
        midiRepository: uninitRepo2,
        midiState: uninitMidiState2,
      );
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      // Should not crash when no practice session is set
      expect(() => uninitHelper2.simulateMidiData(midiData), returnsNormally);

      uninitializedViewModel.dispose();
      uninitMidiState2.dispose();
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

        helper.simulateMidiData(midiData);

        expect(viewModel.midiState.lastNote, "CC: Controller 7 = 100 (Ch: 1)");
      });

      test("should handle program change messages", () {
        final midiData = Uint8List.fromList([0xC0, 42]);

        helper.simulateMidiData(midiData);

        expect(viewModel.midiState.lastNote, "Program Change: 42 (Ch: 1)");
      });

      test("should handle pitch bend messages", () {
        final midiData = Uint8List.fromList([0xE0, 0x00, 0x60]);

        helper.simulateMidiData(midiData);

        expect(viewModel.midiState.lastNote.contains("Pitch Bend"), isTrue);
      });

      test("should filter out clock and active sense messages", () {
        final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
        final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

        viewModel.midiState.setLastNote("Previous message");

        helper.simulateMidiData(clockMessage);
        expect(viewModel.midiState.lastNote, equals("Previous message"));

        helper.simulateMidiData(activeSenseMessage);
        expect(viewModel.midiState.lastNote, equals("Previous message"));
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

    group("Unified Configuration Management", () {
      test("should expose current configuration", () {
        final config = viewModel.currentConfiguration;
        expect(config, isNotNull);
        expect(config!.practiceMode, equals(PracticeMode.scales));
        expect(config.handSelection, isNotNull);
      });

      test("should update configuration with new practice mode", () {
        final newConfig = viewModel.currentConfiguration!.copyWith(
          practiceMode: PracticeMode.arpeggios,
          musicalNote: Field.set(MusicalNote.c),
          arpeggioType: Field.set(ArpeggioType.major),
        );

        var notificationReceived = false;
        viewModel.addListener(() {
          notificationReceived = true;
        });

        viewModel.updateConfiguration(newConfig);

        expect(
          viewModel.practiceSession!.practiceMode,
          equals(PracticeMode.arpeggios),
        );
        expect(notificationReceived, isTrue);
      });

      test("should update configuration with multiple fields at once", () {
        final newConfig = viewModel.currentConfiguration!.copyWith(
          practiceMode: PracticeMode.chordsByType,
          chordType: Field.set(ChordType.minor),
          includeInversions: true,
        );

        viewModel.updateConfiguration(newConfig);

        final session = viewModel.practiceSession!;
        expect(session.practiceMode, equals(PracticeMode.chordsByType));
        expect(session.selectedChordType, equals(ChordType.minor));
        expect(session.includeInversions, isTrue);
      });

      test("should reset practice when configuration changes", () {
        viewModel.startPractice();
        expect(viewModel.practiceSession!.practiceActive, isTrue);

        // Change configuration - should reset practice
        final newConfig = viewModel.currentConfiguration!.copyWith(
          key: Field.set(music.Key.d),
        );
        viewModel.updateConfiguration(newConfig);

        expect(viewModel.practiceSession!.practiceActive, isFalse);
      });

      test("should use Field.set() to clear mode-specific fields", () {
        // Set up with chord type mode
        var config = viewModel.currentConfiguration!.copyWith(
          practiceMode: PracticeMode.chordsByType,
          chordType: Field.set(ChordType.major),
        );
        viewModel.updateConfiguration(config);

        expect(
          viewModel.practiceSession!.selectedChordType,
          equals(ChordType.major),
        );

        // Switch to scales mode and clear chord type
        config = config.copyWith(
          practiceMode: PracticeMode.scales,
          chordType: Field.set(null), // Clear mode-specific field
        );
        viewModel.updateConfiguration(config);

        expect(viewModel.practiceSession!.practiceMode, PracticeMode.scales);
        expect(viewModel.practiceSession!.selectedChordType, isNull);
      });

      test("should notify listeners when configuration updates", () {
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        final config1 = viewModel.currentConfiguration!.copyWith(
          key: Field.set(music.Key.g),
        );
        viewModel.updateConfiguration(config1);

        final config2 = viewModel.currentConfiguration!.copyWith(
          handSelection: HandSelection.left,
        );
        viewModel.updateConfiguration(config2);

        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test("should preserve non-updated fields", () {
        final originalHandSelection =
            viewModel.practiceSession!.selectedHandSelection;

        // Update only key field
        final newConfig = viewModel.currentConfiguration!.copyWith(
          key: Field.set(music.Key.f),
        );
        viewModel.updateConfiguration(newConfig);

        // Hand selection should remain unchanged
        expect(
          viewModel.practiceSession!.selectedHandSelection,
          equals(originalHandSelection),
        );
        expect(viewModel.practiceSession!.selectedKey, equals(music.Key.f));
      });
    });
  });
}
