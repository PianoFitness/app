import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;
import "package:piano_fitness/shared/utils/chords.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("ReferencePageViewModel Tests", () {
    late ReferencePageViewModel viewModel;
    late MidiState mockMidiState;

    setUp(() async {
      viewModel = ReferencePageViewModel();
      mockMidiState = MidiState();
      viewModel.setMidiState(mockMidiState);

      // Wait for any async initialization to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      viewModel.dispose();
      mockMidiState.dispose();

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
          ..setSelectedMode(ReferenceMode.chords);

        expect(viewModel.selectedMode, equals(ReferenceMode.chords));
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
        // Should be present in octaves 3, 4, and 5
        final expectedNotes = <int>{
          // Octave 3
          48, 50, 52, 53, 55, 57, 59, // C3, D3, E3, F3, G3, A3, B3
          // Octave 4
          60, 62, 64, 65, 67, 69, 71, // C4, D4, E4, F4, G4, A4, B4
          // Octave 5
          72, 74, 76, 77, 79, 81, 83, // C5, D5, E5, F5, G5, A5, B5
        };

        expect(highlightedNotes, equals(expectedNotes));
      });

      test("should return correct MIDI notes for D Minor scale", () {
        viewModel.setSelectedKey(scales.Key.d);
        viewModel.setSelectedScaleType(scales.ScaleType.minor);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // D Minor scale: D, E, F, G, A, Bb, C
        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(21)); // 7 notes × 3 octaves

        // Verify some key notes are present
        expect(highlightedNotes.contains(50), isTrue); // D3
        expect(highlightedNotes.contains(62), isTrue); // D4
        expect(highlightedNotes.contains(74), isTrue); // D5
      });

      test("should return correct MIDI notes for F# Lydian scale", () {
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedScaleType(scales.ScaleType.lydian);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        expect(highlightedNotes.isNotEmpty, isTrue);
        expect(highlightedNotes.length, equals(21)); // 7 notes × 3 octaves

        // Verify F# is present in all octaves
        expect(highlightedNotes.contains(54), isTrue); // F#3
        expect(highlightedNotes.contains(66), isTrue); // F#4
        expect(highlightedNotes.contains(78), isTrue); // F#5
      });
    });

    group("Highlighted MIDI Notes - Chords", () {
      test(
        "should return correct MIDI notes for C Major chord root position",
        () {
          viewModel.setSelectedMode(ReferenceMode.chords);
          viewModel.setSelectedKey(scales.Key.c);
          viewModel.setSelectedChordType(ChordType.major);
          viewModel.setSelectedChordInversion(ChordInversion.root);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // C Major chord: C, E, G
          expect(highlightedNotes.isNotEmpty, isTrue);

          // Verify the chord notes are present in multiple octaves
          expect(highlightedNotes.contains(48), isTrue); // C3
          expect(highlightedNotes.contains(52), isTrue); // E3
          expect(highlightedNotes.contains(55), isTrue); // G3
          expect(highlightedNotes.contains(60), isTrue); // C4
          expect(highlightedNotes.contains(64), isTrue); // E4
          expect(highlightedNotes.contains(67), isTrue); // G4
        },
      );

      test(
        "should return correct MIDI notes for A Minor chord first inversion",
        () {
          viewModel.setSelectedMode(ReferenceMode.chords);
          viewModel.setSelectedKey(scales.Key.a);
          viewModel.setSelectedChordType(ChordType.minor);
          viewModel.setSelectedChordInversion(ChordInversion.first);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // A Minor chord: A, C, E
          // First inversion: C, E, A (notes reordered but same pitches)
          expect(highlightedNotes.isNotEmpty, isTrue);

          // Verify the chord notes are present (all octaves)
          expect(highlightedNotes.contains(57), isTrue); // A3
          expect(highlightedNotes.contains(60), isTrue); // C4
          expect(highlightedNotes.contains(64), isTrue); // E4
          expect(highlightedNotes.contains(69), isTrue); // A4
          expect(highlightedNotes.contains(72), isTrue); // C5
          expect(highlightedNotes.contains(76), isTrue); // E5
        },
      );

      test("should return correct MIDI notes for F# Diminished chord", () {
        viewModel.setSelectedMode(ReferenceMode.chords);
        viewModel.setSelectedKey(scales.Key.fSharp);
        viewModel.setSelectedChordType(ChordType.diminished);

        final highlightedNotes = viewModel.getHighlightedMidiNotes();

        // F# Diminished chord: F#, A, C
        expect(highlightedNotes.isNotEmpty, isTrue);

        // Verify the chord notes are present
        expect(highlightedNotes.contains(54), isTrue); // F#3
        expect(highlightedNotes.contains(57), isTrue); // A3
        expect(highlightedNotes.contains(60), isTrue); // C4
      });
    });

    group("Note Playing", () {
      test("should handle virtual note playing", () async {
        const testNote = 60;

        // This test verifies the method doesn't throw
        await viewModel.playNote(testNote);

        // Verify the last note message was set (if MIDI state is available)
        expect(
          mockMidiState.lastNote.contains("Virtual Note ON: $testNote"),
          isTrue,
        );
      });

      test("should handle cases with no MIDI state set", () {
        final viewModelWithoutState = ReferencePageViewModel();

        // Should not crash when no MIDI state is set
        expect(() async => viewModelWithoutState.playNote(60), returnsNormally);

        viewModelWithoutState.dispose();
      });
    });

    group("MIDI State Integration", () {
      test("should set MIDI state correctly", () async {
        final newMidiState = MidiState();

        viewModel.setMidiState(newMidiState);

        // Verify the MIDI state was set (indirectly through functionality)
        await viewModel.playNote(60);

        // Should have updated the last note
        expect(newMidiState.lastNote.contains("Virtual Note ON: 60"), isTrue);

        newMidiState.dispose();
      });
    });

    group("Key to MusicalNote Conversion", () {
      test("should convert all keys correctly", () {
        // Test each key by setting it and verifying the MIDI notes contain expected values
        final testCases = [
          (scales.Key.c, 48), // C3
          (scales.Key.cSharp, 49), // C#3
          (scales.Key.d, 50), // D3
          (scales.Key.dSharp, 51), // D#3
          (scales.Key.e, 52), // E3
          (scales.Key.f, 53), // F3
          (scales.Key.fSharp, 54), // F#3
          (scales.Key.g, 55), // G3
          (scales.Key.gSharp, 56), // G#3
          (scales.Key.a, 57), // A3
          (scales.Key.aSharp, 58), // A#3
          (scales.Key.b, 59), // B3
        ];

        for (final (key, expectedMidiNote) in testCases) {
          viewModel.setSelectedMode(ReferenceMode.chords);
          viewModel.setSelectedKey(key);
          viewModel.setSelectedChordType(ChordType.major);

          final highlightedNotes = viewModel.getHighlightedMidiNotes();

          // The root note should be present in octave 3
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
