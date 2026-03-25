import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as scales;
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("ReferencePageViewModel Tests", () {
    late ReferencePageViewModel viewModel;
    late MockIMidiRepository mockMidiRepository;
    late MidiState midiState;

    setUp(() async {
      mockMidiRepository = MockIMidiRepository();
      midiState = MidiState();
      viewModel = ReferencePageViewModel(
        midiCoordinator: MidiCoordinator(mockMidiRepository),
        midiRepository: mockMidiRepository,
        midiState: midiState,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      viewModel.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    test("should initialize with default values", () {
      expect(viewModel.selectedMode, equals(ReferenceMode.scales));
      expect(viewModel.selectedKey, equals(scales.Key.c));
      expect(viewModel.selectedScaleType, equals(scales.ScaleType.major));
      expect(viewModel.selectedChordType, equals(ChordType.major));
      expect(viewModel.selectedChordInversion, equals(ChordInversion.root));
    });

    group("Mode Selection", () {
      test("should update selected mode and notify listeners", () {
        var notified = false;
        viewModel
          ..addListener(() {
            notified = true;
          })
          ..setSelectedMode(ReferenceMode.chordTypes);

        expect(viewModel.selectedMode, equals(ReferenceMode.chordTypes));
        expect(notified, isTrue);
      });

      test("should not notify listeners if mode is the same", () {
        var notified = false;
        viewModel
          ..addListener(() {
            notified = true;
          })
          ..setSelectedMode(ReferenceMode.scales); // Same as default

        expect(notified, isFalse);
      });
    });

    group("Key Selection", () {
      test("should update selected key and notify listeners", () {
        var notified = false;
        viewModel
          ..addListener(() {
            notified = true;
          })
          ..setSelectedKey(scales.Key.fSharp);

        expect(viewModel.selectedKey, equals(scales.Key.fSharp));
        expect(notified, isTrue);
      });

      test("should not notify listeners if key is the same", () {
        var notified = false;
        viewModel
          ..addListener(() {
            notified = true;
          })
          ..setSelectedKey(scales.Key.c); // Same as default

        expect(notified, isFalse);
      });
    });

    group("Scale Type Selection", () {
      test("should update selected scale type and notify listeners", () {
        var notified = false;
        viewModel
          ..addListener(() {
            notified = true;
          })
          ..setSelectedScaleType(scales.ScaleType.minor);

        expect(viewModel.selectedScaleType, equals(scales.ScaleType.minor));
        expect(notified, isTrue);
      });

      test("should not notify listeners if scale type is the same", () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setSelectedScaleType(
          scales.ScaleType.major,
        ); // Same as default

        expect(notified, isFalse);
      });
    });

    group("Chord Type Selection", () {
      test("should update selected chord type and notify listeners", () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setSelectedChordType(ChordType.minor);

        expect(viewModel.selectedChordType, equals(ChordType.minor));
        expect(notified, isTrue);
      });

      test("should not notify listeners if chord type is the same", () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setSelectedChordType(ChordType.major); // Same as default

        expect(notified, isFalse);
      });
    });

    group("Chord Inversion Selection", () {
      test("should update selected chord inversion and notify listeners", () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setSelectedChordInversion(ChordInversion.first);

        expect(viewModel.selectedChordInversion, equals(ChordInversion.first));
        expect(notified, isTrue);
      });

      test("should not notify listeners if chord inversion is the same", () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setSelectedChordInversion(
          ChordInversion.root,
        ); // Same as default

        expect(notified, isFalse);
      });
    });

    group("Highlighted MIDI Notes - Scales", () {
      test("should return correct MIDI notes for C Major scale", () {
        viewModel.setSelectedKey(scales.Key.c);
        viewModel.setSelectedScaleType(scales.ScaleType.major);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // C Major scale: C4, D4, E4, F4, G4, A4, B4
        final expectedNotes = {
          MidiNote(60),
          MidiNote(62),
          MidiNote(64),
          MidiNote(65),
          MidiNote(67),
          MidiNote(69),
          MidiNote(71),
        };

        expect(highlightedNotes, equals(expectedNotes));
      });

      test("should return correct MIDI notes for D Minor scale", () {
        viewModel.setSelectedKey(scales.Key.d);
        viewModel.setSelectedScaleType(scales.ScaleType.minor);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // D Minor scale: D, E, F, G, A, Bb, C
        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(7));

        expect(highlightedNotes.contains(MidiNote(62)), isTrue); // D4
        expect(highlightedNotes.contains(MidiNote(64)), isTrue); // E4
        expect(highlightedNotes.contains(MidiNote(65)), isTrue); // F4
      });

      test("should return correct MIDI notes for F# Lydian scale", () {
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedScaleType(scales.ScaleType.lydian);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(7));

        // F# Lydian scale: F#, G#, A#, B#(C), C#, D#, E#(F)
        expect(highlightedNotes.contains(MidiNote(66)), isTrue); // F#4
        expect(highlightedNotes.contains(MidiNote(68)), isTrue); // G#4
        expect(highlightedNotes.contains(MidiNote(70)), isTrue); // A#4
        expect(highlightedNotes.contains(MidiNote(72)), isTrue); // B#4 (C5)
      });
    });

    group("Highlighted MIDI Notes - Chords", () {
      test(
        "should return correct MIDI notes for C Major chord root position",
        () {
          viewModel.setSelectedMode(ReferenceMode.chordTypes);
          viewModel.setSelectedKey(scales.Key.c);
          viewModel.setSelectedChordType(ChordType.major);
          viewModel.setSelectedChordInversion(ChordInversion.root);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // C Major chord: C4, E4, G4
          expect(highlightedNotes.isNotEmpty, isTrue);
          expect(highlightedNotes.length, equals(3));
          expect(highlightedNotes.contains(MidiNote(60)), isTrue); // C4
          expect(highlightedNotes.contains(MidiNote(64)), isTrue); // E4
          expect(highlightedNotes.contains(MidiNote(67)), isTrue); // G4
        },
      );

      test(
        "should return correct MIDI notes for A Minor chord first inversion",
        () {
          viewModel.setSelectedMode(ReferenceMode.chordTypes);
          viewModel.setSelectedKey(scales.Key.a);
          viewModel.setSelectedChordType(ChordType.minor);
          viewModel.setSelectedChordInversion(ChordInversion.first);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // A Minor first inversion: C5, E5, A5 (ascending voicing)
          expect(highlightedNotes.isNotEmpty, isTrue);
          expect(highlightedNotes.length, equals(3));
          expect(highlightedNotes.contains(MidiNote(72)), isTrue); // C5
          expect(highlightedNotes.contains(MidiNote(76)), isTrue); // E5
          expect(highlightedNotes.contains(MidiNote(81)), isTrue); // A5
        },
      );

      test("should return correct MIDI notes for F# Diminished chord", () {
        viewModel.setSelectedMode(ReferenceMode.chordTypes);
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedChordType(ChordType.diminished);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // F# Diminished chord: F#4, A4, C5
        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(3));
        expect(highlightedNotes.contains(MidiNote(66)), isTrue); // F#4
        expect(highlightedNotes.contains(MidiNote(69)), isTrue); // A4
        expect(highlightedNotes.contains(MidiNote(72)), isTrue); // C5
      });
    });

    group("Note Playing", () {
      test("should handle virtual note playing", () async {
        final testNote = MidiNote(60);

        await viewModel.playNote(testNote);

        expect(
          viewModel.localMidiState.lastNote.contains(
            "Virtual Note ON: ${testNote.value}",
          ),
          isTrue,
        );
      });

      test("should play note from NotePosition", () async {
        // C5 = MIDI 72 ((5+1)*12 + 0)
        final position = NotePosition(note: Note.C, octave: 5);
        await viewModel.playNoteFromPosition(position);

        expect(
          viewModel.localMidiState.lastNote.contains("Virtual Note ON: 72"),
          isTrue,
        );
      });

      test("should handle note playing with local MIDI state", () async {
        final localRepo = MockIMidiRepository();
        final localMidiState = MidiState();
        final viewModelWithLocalState = ReferencePageViewModel(
          midiCoordinator: MidiCoordinator(localRepo),
          midiRepository: localRepo,
          midiState: localMidiState,
        );

        await expectLater(
          () async => viewModelWithLocalState.playNote(MidiNote(60)),
          returnsNormally,
        );

        expect(
          viewModelWithLocalState.localMidiState.lastNote.contains("Virtual"),
          isTrue,
        );

        viewModelWithLocalState.dispose();
        localMidiState.dispose();
      });
    });

    group("MIDI State Integration", () {
      test("should use local MIDI state correctly", () async {
        await viewModel.playNote(MidiNote(60));

        expect(
          viewModel.localMidiState.lastNote.contains("Virtual Note ON: 60"),
          isTrue,
        );
      });
    });

    group("Highlighted Note Positions", () {
      test("should return NotePositions for current scale highlights", () {
        viewModel.setSelectedKey(scales.Key.c);
        viewModel.setSelectedScaleType(scales.ScaleType.major);

        final positions = viewModel.highlightedNotePositions;

        // C major at baseOctave (4): 7 scale degrees (no octave duplicate).
        // MIDI 60→C4, 62→D4, 64→E4, 65→F4, 67→G4, 69→A4, 71→B4.
        // Order mirrors insertion into the LinkedHashSet in _getScaleMidiNotes().
        final expectedPositions = [
          NotePosition(note: Note.C),
          NotePosition(note: Note.D),
          NotePosition(note: Note.E),
          NotePosition(note: Note.F),
          NotePosition(note: Note.G),
          NotePosition(note: Note.A),
          NotePosition(note: Note.B),
        ];
        expect(positions, equals(expectedPositions));
      });
    });

    group("Key to MusicalNote Conversion", () {
      test("should convert all keys correctly", () {
        final testCases = [
          (scales.Key.c, 60), // C4
          (scales.Key.cSharp, 61), // C#4
          (scales.Key.d, 62), // D4
          (scales.Key.dSharp, 63), // D#4
          (scales.Key.e, 64), // E4
          (scales.Key.f, 65), // F4
          (scales.Key.fSharp, 66), // F#4
          (scales.Key.g, 67), // G4
          (scales.Key.gSharp, 68), // G#4
          (scales.Key.a, 69), // A4
          (scales.Key.aSharp, 70), // A#4
          (scales.Key.b, 71), // B4
        ];

        for (final (key, expectedMidiValue) in testCases) {
          viewModel.setSelectedMode(ReferenceMode.chordTypes);
          viewModel.setSelectedKey(key);
          viewModel.setSelectedChordType(ChordType.major);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          expect(
            highlightedNotes.contains(MidiNote(expectedMidiValue)),
            isTrue,
            reason: "Key $key should produce MIDI note $expectedMidiValue",
          );
        }
      });
    });
  });
}
