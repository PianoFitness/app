import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:piano_fitness/utils/arpeggios.dart";
import "package:piano_fitness/utils/scales.dart" as music;
import "package:piano_fitness/widgets/practice_settings_panel.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("PracticePageViewModel Tests", () {
    late PracticePageViewModel viewModel;
    late MidiState mockMidiState;
    bool exerciseCompletedCalled = false;
    List<NotePosition> receivedHighlightedNotes = [];

    setUp(() {
      viewModel = PracticePageViewModel(
        initialChannel: 3,
      );
      mockMidiState = MidiState();
      exerciseCompletedCalled = false;
      receivedHighlightedNotes = [];

      viewModel.setMidiState(mockMidiState);
      viewModel.initializePracticeSession(
        onExerciseCompleted: () {
          exerciseCompletedCalled = true;
        },
        onHighlightedNotesChanged: (notes) {
          receivedHighlightedNotes = notes;
        },
        initialMode: PracticeMode.scales,
      );
    });

    tearDown(() {
      viewModel.dispose();
      mockMidiState.dispose();
    });

    test("should initialize with correct MIDI channel", () {
      expect(viewModel.midiChannel, equals(3));
      expect(mockMidiState.selectedChannel, equals(3));
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

      expect(mockMidiState.activeNotes.contains(60), isTrue);
      expect(mockMidiState.lastNote, "Note ON: 60 (Ch: 1, Vel: 100)");
      expect(mockMidiState.hasRecentActivity, isTrue);
    });

    test("should handle MIDI data and update state for note off events", () {
      // First add a note
      mockMidiState.noteOn(60, 100, 1);
      expect(mockMidiState.activeNotes.contains(60), isTrue);

      final midiData = Uint8List.fromList([0x80, 60, 0]);

      viewModel.handleMidiData(midiData);

      expect(mockMidiState.activeNotes.contains(60), isFalse);
      expect(mockMidiState.lastNote, "Note OFF: 60 (Ch: 1)");
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
      viewModel.addListener(() {
        notificationReceived = true;
      });

      viewModel.setPracticeMode(PracticeMode.chords);

      expect(
        viewModel.practiceSession!.practiceMode,
        equals(PracticeMode.chords),
      );
      expect(notificationReceived, isTrue);
    });

    test("should change selected key and notify listeners", () {
      var notificationReceived = false;
      viewModel.addListener(() {
        notificationReceived = true;
      });

      viewModel.setSelectedKey(music.Key.d);

      expect(viewModel.practiceSession!.selectedKey, equals(music.Key.d));
      expect(notificationReceived, isTrue);
    });

    test("should change selected scale type and notify listeners", () {
      var notificationReceived = false;
      viewModel.addListener(() {
        notificationReceived = true;
      });

      viewModel.setSelectedScaleType(music.ScaleType.minor);

      expect(
        viewModel.practiceSession!.selectedScaleType,
        equals(music.ScaleType.minor),
      );
      expect(notificationReceived, isTrue);
    });

    test("should change selected arpeggio type and notify listeners", () {
      var notificationReceived = false;
      viewModel.addListener(() {
        notificationReceived = true;
      });

      viewModel.setSelectedArpeggioType(ArpeggioType.minor);

      expect(
        viewModel.practiceSession!.selectedArpeggioType,
        equals(ArpeggioType.minor),
      );
      expect(notificationReceived, isTrue);
    });

    test("should calculate appropriate highlighted notes for display", () {
      // Test when ViewModel has highlighted notes
      final testNotes = [
        NotePosition(note: Note.C, octave: 4),
        NotePosition(note: Note.E, octave: 4),
      ];
      receivedHighlightedNotes = testNotes;
      viewModel.practiceSession!.onHighlightedNotesChanged(testNotes);

      final result = viewModel.getDisplayHighlightedNotes(mockMidiState);
      expect(result, equals(testNotes));

      // Test when ViewModel has no highlighted notes, falls back to MidiState
      viewModel.practiceSession!.onHighlightedNotesChanged([]);
      mockMidiState.noteOn(60, 100, 1);

      final fallbackResult = viewModel.getDisplayHighlightedNotes(
        mockMidiState,
      );
      expect(fallbackResult, equals(mockMidiState.highlightedNotePositions));
    });

    test("should calculate practice range correctly", () {
      final range = viewModel.calculatePracticeRange();

      expect(range, isNotNull);
      expect(range, isA<NoteRange>());
    });

    test("should calculate key width correctly", () {
      const testScreenWidth = 800.0;

      final keyWidth = viewModel.calculateKeyWidth(testScreenWidth);

      expect(keyWidth, greaterThan(0));
      expect(keyWidth, isA<double>());
    });

    test("should convert note positions to MIDI numbers correctly", () {
      // Test C4 (middle C)
      final c4Position = NotePosition(note: Note.C, octave: 4);
      expect(viewModel.convertNotePositionToMidi(c4Position), equals(60));

      // Test C#4
      final cSharp4Position = NotePosition(
        note: Note.C,
        octave: 4,
        accidental: Accidental.Sharp,
      );
      expect(viewModel.convertNotePositionToMidi(cSharp4Position), equals(61));

      // Test A0 (lowest piano key)
      final a0Position = NotePosition(note: Note.A, octave: 0);
      expect(viewModel.convertNotePositionToMidi(a0Position), equals(21));
    });

    test("should handle virtual note playing", () async {
      const testNote = 60;

      // This test verifies the method doesn't throw
      await viewModel.playVirtualNote(testNote);

      // In a real implementation, this would trigger practice session updates
      expect(viewModel.practiceSession, isNotNull);
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
        final testNotes = [
          NotePosition(note: Note.C, octave: 4),
          NotePosition(note: Note.E, octave: 4),
          NotePosition(note: Note.G, octave: 4),
        ];

        expect(receivedHighlightedNotes, isEmpty);

        // Simulate highlighted notes change
        viewModel.practiceSession!.onHighlightedNotesChanged(testNotes);

        expect(receivedHighlightedNotes, equals(testNotes));
        expect(viewModel.highlightedNotes, equals(testNotes));
      });
    });

    group("MIDI Data Processing Edge Cases", () {
      test("should handle control change messages", () {
        final midiData = Uint8List.fromList([0xB0, 7, 100]);

        viewModel.handleMidiData(midiData);

        expect(mockMidiState.lastNote, "CC: Controller 7 = 100 (Ch: 1)");
      });

      test("should handle program change messages", () {
        final midiData = Uint8List.fromList([0xC0, 42]);

        viewModel.handleMidiData(midiData);

        expect(mockMidiState.lastNote, "Program Change: 42 (Ch: 1)");
      });

      test("should handle pitch bend messages", () {
        final midiData = Uint8List.fromList([0xE0, 0x00, 0x60]);

        viewModel.handleMidiData(midiData);

        expect(mockMidiState.lastNote.contains("Pitch Bend"), isTrue);
      });

      test("should filter out clock and active sense messages", () {
        final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
        final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

        mockMidiState.setLastNote("Previous message");

        viewModel.handleMidiData(clockMessage);
        expect(mockMidiState.lastNote, equals("Previous message"));

        viewModel.handleMidiData(activeSenseMessage);
        expect(mockMidiState.lastNote, equals("Previous message"));
      });
    });

    group("Practice Settings Management", () {
      test("should handle all practice mode changes", () {
        final modes = [
          PracticeMode.scales,
          PracticeMode.chords,
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
    });
  });
}
