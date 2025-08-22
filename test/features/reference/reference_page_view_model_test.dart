import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;
import "package:piano_fitness/shared/utils/chords.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("ReferencePageViewModel Tests", () {
    late ReferencePageViewModel viewModel;

    setUp(() async {
      viewModel = ReferencePageViewModel();
      // Note: ReferencePageViewModel now has its own local MIDI state
      // No need to set external MIDI state

      // Wait for any async initialization to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      viewModel.dispose();
      // Note: Local MIDI state is disposed by the viewModel

      // Wait for any pending async operations to complete
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
          ..setSelectedMode(ReferenceMode.chordsByKey);

        expect(viewModel.selectedMode, equals(ReferenceMode.chordsByKey));
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

        // C Major scale: C, D, E, F, G, A, B
        // Should be present in octave 4 only
        final expectedNotes = <int>{
          60, 62, 64, 65, 67, 69, 71, // C4, D4, E4, F4, G4, A4, B4
        };

        expect(highlightedNotes, equals(expectedNotes));
      });

      test("should return correct MIDI notes for D Minor scale", () {
        viewModel.setSelectedKey(scales.Key.d);
        viewModel.setSelectedScaleType(scales.ScaleType.minor);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // D Minor scale: D, E, F, G, A, Bb, C
        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(7)); // 7 notes × 1 octave

        // Verify key notes are present in octave 4
        expect(highlightedNotes.contains(62), isTrue); // D4
        expect(highlightedNotes.contains(64), isTrue); // E4
        expect(highlightedNotes.contains(65), isTrue); // F4
      });

      test("should return correct MIDI notes for F# Lydian scale", () {
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedScaleType(scales.ScaleType.lydian);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(7)); // 7 notes × 1 octave

        // F# Lydian scale: F#, G#, A#, B#(C), C#, D#, E#(F)
        expect(highlightedNotes.contains(66), isTrue); // F#4 (root)
        expect(highlightedNotes.contains(68), isTrue); // G#4
        expect(highlightedNotes.contains(70), isTrue); // A#4
        expect(highlightedNotes.contains(72), isTrue); // B#4 (C5)
      });
    });

    group("Highlighted MIDI Notes - Chords", () {
      test(
        "should return correct MIDI notes for C Major chord root position",
        () {
          viewModel.setSelectedMode(ReferenceMode.chordsByKey);
          viewModel.setSelectedKey(scales.Key.c);
          viewModel.setSelectedChordType(ChordType.major);
          viewModel.setSelectedChordInversion(ChordInversion.root);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // C Major chord: C, E, G
          expect(highlightedNotes.isNotEmpty, isTrue);
          expect(highlightedNotes.length, equals(3)); // 3 notes × 1 octave

          // Verify the chord notes are present in octave 4 only
          expect(highlightedNotes.contains(60), isTrue); // C4
          expect(highlightedNotes.contains(64), isTrue); // E4
          expect(highlightedNotes.contains(67), isTrue); // G4
        },
      );

      test(
        "should return correct MIDI notes for A Minor chord first inversion",
        () {
          viewModel.setSelectedMode(ReferenceMode.chordsByKey);
          viewModel.setSelectedKey(scales.Key.a);
          viewModel.setSelectedChordType(ChordType.minor);
          viewModel.setSelectedChordInversion(ChordInversion.first);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // A Minor chord: A, C, E
          // First inversion: C, E, A (proper ascending voicing)
          expect(highlightedNotes.isNotEmpty, isTrue);
          expect(highlightedNotes.length, equals(3)); // 3 notes

          // Verify the chord notes are present - using proper ascending inversion voicing
          // First inversion should be C-E-A ascending, not A going down an octave
          expect(highlightedNotes.contains(72), isTrue); // C5
          expect(highlightedNotes.contains(76), isTrue); // E5
          expect(
            highlightedNotes.contains(81),
            isTrue,
          ); // A6 (properly ascending)
        },
      );

      test("should return correct MIDI notes for F# Diminished chord", () {
        viewModel.setSelectedMode(ReferenceMode.chordsByKey);
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedChordType(ChordType.diminished);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // F# Diminished chord: F#, A, C
        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(3)); // 3 notes × 1 octave

        // Verify the chord notes are present in octave 4 only
        expect(highlightedNotes.contains(66), isTrue); // F#4
        expect(highlightedNotes.contains(69), isTrue); // A4
        expect(
          highlightedNotes.contains(72),
          isTrue,
        ); // C5 (wraps to next octave)
      });
    });

    group("Note Playing", () {
      test("should handle virtual note playing", () async {
        const testNote = 60;

        // This test verifies the method doesn't throw
        await viewModel.playNote(testNote);

        // Verify the note was played through local MIDI state
        expect(
          viewModel.localMidiState.lastNote.contains(
            "Virtual Note ON: $testNote",
          ),
          isTrue,
        );
      });

      test("should handle note playing with local MIDI state", () async {
        final viewModelWithLocalState = ReferencePageViewModel();

        // Should not crash and should work with local MIDI state
        await expectLater(
          () async => viewModelWithLocalState.playNote(60),
          returnsNormally,
        );

        // Verify the note was processed in local state
        expect(
          viewModelWithLocalState.localMidiState.lastNote.contains("Virtual"),
          isTrue,
        );

        viewModelWithLocalState.dispose();
      });
    });

    group("MIDI State Integration", () {
      test("should use local MIDI state correctly", () async {
        // ReferencePageViewModel now uses its own local MIDI state
        // Verify the MIDI state functionality works through note playing
        await viewModel.playNote(60);

        // Should have updated the last note in local MIDI state
        expect(
          viewModel.localMidiState.lastNote.contains("Virtual Note ON: 60"),
          isTrue,
        );
      });
    });

    group("Key to MusicalNote Conversion", () {
      test("should convert all keys correctly", () {
        // Test each key by setting it and verifying the MIDI notes contain expected values
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

        for (final (key, expectedMidiNote) in testCases) {
          viewModel.setSelectedMode(ReferenceMode.chordsByKey);
          viewModel.setSelectedKey(key);
          viewModel.setSelectedChordType(ChordType.major);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // The root note should be present in octave 4
          expect(
            highlightedNotes.contains(expectedMidiNote),
            isTrue,
            reason: "Key $key should produce MIDI note $expectedMidiNote",
          );
        }
      });
    });
  });
}
