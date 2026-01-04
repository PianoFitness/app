import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

void main() {
  group("ChordDefinitions", () {
    group("Basic chord generation", () {
      test("should create C Major chord correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );

        expect(chord.rootNote, equals(MusicalNote.c));
        expect(chord.type, equals(ChordType.major));
        expect(chord.inversion, equals(ChordInversion.root));
        expect(chord.name, equals("C"));
        expect(
          chord.notes,
          equals([MusicalNote.c, MusicalNote.e, MusicalNote.g]),
        );
      });

      test("should create D minor chord correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.d,
          ChordType.minor,
          ChordInversion.root,
        );

        expect(chord.rootNote, equals(MusicalNote.d));
        expect(chord.type, equals(ChordType.minor));
        expect(chord.inversion, equals(ChordInversion.root));
        expect(chord.name, equals("Dm"));
        expect(
          chord.notes,
          equals([MusicalNote.d, MusicalNote.f, MusicalNote.a]),
        );
      });

      test("should create B diminished chord correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.b,
          ChordType.diminished,
          ChordInversion.root,
        );

        expect(chord.rootNote, equals(MusicalNote.b));
        expect(chord.type, equals(ChordType.diminished));
        expect(chord.inversion, equals(ChordInversion.root));
        expect(chord.name, equals("B°"));
        expect(
          chord.notes,
          equals([MusicalNote.b, MusicalNote.d, MusicalNote.f]),
        );
      });

      test("should create C augmented chord correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.augmented,
          ChordInversion.root,
        );

        expect(chord.rootNote, equals(MusicalNote.c));
        expect(chord.type, equals(ChordType.augmented));
        expect(chord.inversion, equals(ChordInversion.root));
        expect(chord.name, equals("C+"));
        expect(
          chord.notes,
          equals([MusicalNote.c, MusicalNote.e, MusicalNote.gSharp]),
        );
      });
    });

    group("Chord inversions", () {
      test("should create C Major 1st inversion correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.first,
        );

        expect(chord.inversion, equals(ChordInversion.first));
        expect(chord.name, equals("C (1st inv)"));
        expect(
          chord.notes,
          equals([MusicalNote.e, MusicalNote.g, MusicalNote.c]),
        );
      });

      test("should create C Major 2nd inversion correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.second,
        );

        expect(chord.inversion, equals(ChordInversion.second));
        expect(chord.name, equals("C (2nd inv)"));
        expect(
          chord.notes,
          equals([MusicalNote.g, MusicalNote.c, MusicalNote.e]),
        );
      });

      test("should create D minor inversions correctly", () {
        final root = ChordDefinitions.getChord(
          MusicalNote.d,
          ChordType.minor,
          ChordInversion.root,
        );
        final first = ChordDefinitions.getChord(
          MusicalNote.d,
          ChordType.minor,
          ChordInversion.first,
        );
        final second = ChordDefinitions.getChord(
          MusicalNote.d,
          ChordType.minor,
          ChordInversion.second,
        );

        expect(
          root.notes,
          equals([MusicalNote.d, MusicalNote.f, MusicalNote.a]),
        );
        expect(
          first.notes,
          equals([MusicalNote.f, MusicalNote.a, MusicalNote.d]),
        );
        expect(
          second.notes,
          equals([MusicalNote.a, MusicalNote.d, MusicalNote.f]),
        );

        expect(root.name, equals("Dm"));
        expect(first.name, equals("Dm (1st inv)"));
        expect(second.name, equals("Dm (2nd inv)"));
      });
    });

    group("MIDI note generation", () {
      test("should generate correct MIDI notes for C Major root position", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );

        final midiNotes = chord.getMidiNotes(4);
        expect(midiNotes, equals([60, 64, 67])); // C4, E4, G4
      });

      test("should generate correct MIDI notes for C Major 1st inversion", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.first,
        );

        final midiNotes = chord.getMidiNotes(4);
        expect(midiNotes, equals([64, 67, 72])); // E4, G4, C5
      });

      test("should generate correct MIDI notes for C Major 2nd inversion", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.second,
        );

        final midiNotes = chord.getMidiNotes(4);
        expect(midiNotes, equals([67, 72, 76])); // G4, C5, E5
      });

      test("should handle different octaves correctly", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );

        final octave3 = chord.getMidiNotes(3);
        final octave4 = chord.getMidiNotes(4);
        final octave5 = chord.getMidiNotes(5);

        expect(octave3, equals([48, 52, 55])); // C3, E3, G3
        expect(octave4, equals([60, 64, 67])); // C4, E4, G4
        expect(octave5, equals([72, 76, 79])); // C5, E5, G5
      });
    });

    group("Chord types for scales", () {
      test("should determine correct chord types for C Major scale", () {
        final chordTypes = ChordDefinitions.getChordsInKey(
          Key.c,
          ScaleType.major,
        );

        expect(chordTypes.length, equals(7));
        expect(chordTypes[0], equals(ChordType.major)); // I - C Major
        expect(chordTypes[1], equals(ChordType.minor)); // ii - D minor
        expect(chordTypes[2], equals(ChordType.minor)); // iii - E minor
        expect(chordTypes[3], equals(ChordType.major)); // IV - F Major
        expect(chordTypes[4], equals(ChordType.major)); // V - G Major
        expect(chordTypes[5], equals(ChordType.minor)); // vi - A minor
        expect(
          chordTypes[6],
          equals(ChordType.diminished),
        ); // vii° - B diminished
      });

      test("should determine correct chord types for G Major scale", () {
        final chordTypes = ChordDefinitions.getChordsInKey(
          Key.g,
          ScaleType.major,
        );

        expect(chordTypes.length, equals(7));
        expect(chordTypes[0], equals(ChordType.major)); // I - G Major
        expect(chordTypes[1], equals(ChordType.minor)); // ii - A minor
        expect(chordTypes[2], equals(ChordType.minor)); // iii - B minor
        expect(chordTypes[3], equals(ChordType.major)); // IV - C Major
        expect(chordTypes[4], equals(ChordType.major)); // V - D Major
        expect(chordTypes[5], equals(ChordType.minor)); // vi - E minor
        expect(
          chordTypes[6],
          equals(ChordType.diminished),
        ); // vii° - F# diminished
      });

      test("should determine correct chord types for A minor scale", () {
        final chordTypes = ChordDefinitions.getChordsInKey(
          Key.a,
          ScaleType.minor,
        );

        expect(chordTypes.length, equals(7));
        expect(chordTypes[0], equals(ChordType.minor)); // i - A minor
        expect(
          chordTypes[1],
          equals(ChordType.diminished),
        ); // ii° - B diminished
        expect(chordTypes[2], equals(ChordType.major)); // III - C Major
        expect(chordTypes[3], equals(ChordType.minor)); // iv - D minor
        expect(chordTypes[4], equals(ChordType.minor)); // v - E minor
        expect(chordTypes[5], equals(ChordType.major)); // VI - F Major
        expect(chordTypes[6], equals(ChordType.major)); // VII - G Major
      });
    });

    group("Key triad progressions", () {
      test("should generate correct triad progression for C Major", () {
        final progression = ChordDefinitions.getKeyTriadProgression(
          Key.c,
          ScaleType.major,
        );

        expect(progression.length, equals(21)); // 7 chords × 3 inversions each

        // First chord (C Major) in all inversions
        expect(progression[0].name, equals("C"));
        expect(progression[1].name, equals("C (1st inv)"));
        expect(progression[2].name, equals("C (2nd inv)"));

        // Second chord (D minor) in all inversions
        expect(progression[3].name, equals("Dm"));
        expect(progression[4].name, equals("Dm (1st inv)"));
        expect(progression[5].name, equals("Dm (2nd inv)"));

        // Third chord (E minor) in all inversions
        expect(progression[6].name, equals("Em"));
        expect(progression[7].name, equals("Em (1st inv)"));
        expect(progression[8].name, equals("Em (2nd inv)"));

        // Last chord (B diminished) in all inversions
        expect(progression[18].name, equals("B°"));
        expect(progression[19].name, equals("B° (1st inv)"));
        expect(progression[20].name, equals("B° (2nd inv)"));
      });

      test("should generate progression with correct chord types", () {
        final progression = ChordDefinitions.getKeyTriadProgression(
          Key.c,
          ScaleType.major,
        );

        // Check that chord types are preserved across inversions
        for (var i = 0; i < 7; i++) {
          final baseIndex = i * 3;
          final root = progression[baseIndex];
          final first = progression[baseIndex + 1];
          final second = progression[baseIndex + 2];

          expect(root.type, equals(first.type));
          expect(first.type, equals(second.type));
          expect(root.rootNote, equals(first.rootNote));
          expect(first.rootNote, equals(second.rootNote));
        }
      });
    });

    group("Chord progression MIDI sequence", () {
      test("should generate correct MIDI sequence for C Major progression", () {
        final midiSequence = ChordDefinitions.getChordProgressionMidiSequence(
          Key.c,
          ScaleType.major,
          4,
        );

        expect(midiSequence.length, equals(63)); // 21 chords × 3 notes each

        // First 9 notes should be C Major in all inversions
        final expectedStart = [
          60, 64, 67, // C Major root: C4, E4, G4
          64, 67, 72, // C Major 1st: E4, G4, C5
          67, 72, 76, // C Major 2nd: G4, C5, E5
        ];

        expect(midiSequence.sublist(0, 9), equals(expectedStart));
      });

      test("should maintain correct octave relationships in inversions", () {
        final progression = ChordDefinitions.getKeyTriadProgression(
          Key.c,
          ScaleType.major,
        );

        for (var i = 0; i < progression.length; i += 3) {
          final root = progression[i];
          final first = progression[i + 1];
          final second = progression[i + 2];

          final rootMidi = root.getMidiNotes(4);
          final firstMidi = first.getMidiNotes(4);
          final secondMidi = second.getMidiNotes(4);

          // All inversions should span reasonable octave range
          expect(
            rootMidi.last - rootMidi.first,
            lessThanOrEqualTo(24),
          ); // Within two octaves
          expect(firstMidi.last - firstMidi.first, lessThanOrEqualTo(24));
          expect(secondMidi.last - secondMidi.first, lessThanOrEqualTo(24));

          // Inversions should be properly voiced (ascending)
          expect(firstMidi[0], lessThan(firstMidi[1]));
          expect(firstMidi[1], lessThan(firstMidi[2]));
          expect(secondMidi[0], lessThan(secondMidi[1]));
          expect(secondMidi[1], lessThan(secondMidi[2]));
        }
      });
    });

    group("All chord types in all keys", () {
      // Helper to determine expected note count based on chord type
      int expectedNoteCount(ChordType type) {
        switch (type) {
          case ChordType.major:
          case ChordType.minor:
          case ChordType.diminished:
          case ChordType.augmented:
            return 3; // Triads
          case ChordType.major7:
          case ChordType.dominant7:
          case ChordType.minor7:
          case ChordType.halfDiminished7:
          case ChordType.diminished7:
          case ChordType.minorMajor7:
          case ChordType.augmented7:
            return 4; // Seventh chords
        }
      }

      test("should generate chords for all chord types and keys", () {
        for (final note in MusicalNote.values) {
          for (final type in ChordType.values) {
            // Skip third inversion for triads (only valid for seventh chords)
            final inversions =
                type == ChordType.major ||
                    type == ChordType.minor ||
                    type == ChordType.diminished ||
                    type == ChordType.augmented
                ? [
                    ChordInversion.root,
                    ChordInversion.first,
                    ChordInversion.second,
                  ]
                : ChordInversion.values;

            for (final inversion in inversions) {
              final chord = ChordDefinitions.getChord(note, type, inversion);
              final expectedNotes = expectedNoteCount(type);

              expect(chord.rootNote, equals(note));
              expect(chord.type, equals(type));
              expect(chord.inversion, equals(inversion));
              expect(chord.notes.length, equals(expectedNotes));
              expect(chord.name, isNotEmpty);

              // Test MIDI generation
              final midiNotes = chord.getMidiNotes(4);
              expect(midiNotes.length, equals(expectedNotes));

              // MIDI notes should be in ascending order for proper voicing
              for (var i = 0; i < midiNotes.length - 1; i++) {
                expect(
                  midiNotes[i],
                  lessThan(midiNotes[i + 1]),
                  reason:
                      "MIDI notes should be ascending for $note $type ($inversion)",
                );
              }
            }
          }
        }
      });
    });

    group("Chord naming", () {
      final expectedNames = {
        ChordType.major: "",
        ChordType.minor: "m",
        ChordType.diminished: "°",
        ChordType.augmented: "+",
      };

      for (final entry in expectedNames.entries) {
        test("should name ${entry.key} chords correctly", () {
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            entry.key,
            ChordInversion.root,
          );
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            entry.key,
            ChordInversion.first,
          );
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            entry.key,
            ChordInversion.second,
          );

          expect(root.name, equals("C${entry.value}"));
          expect(first.name, equals("C${entry.value} (1st inv)"));
          expect(second.name, equals("C${entry.value} (2nd inv)"));
        });
      }
    });

    group("Chord interval validation", () {
      test("should have correct intervals for each chord type", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );
        final notes = chord.notes;

        // Calculate intervals between chord tones
        final firstInterval = (notes[1].index - notes[0].index + 12) % 12;
        final secondInterval = (notes[2].index - notes[1].index + 12) % 12;

        expect(firstInterval, equals(4)); // Major third
        expect(secondInterval, equals(3)); // Minor third
      });

      test("should have correct intervals for minor chords", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.minor,
          ChordInversion.root,
        );
        final notes = chord.notes;

        final firstInterval = (notes[1].index - notes[0].index + 12) % 12;
        final secondInterval = (notes[2].index - notes[1].index + 12) % 12;

        expect(firstInterval, equals(3)); // Minor third
        expect(secondInterval, equals(4)); // Major third
      });

      test("should have correct intervals for diminished chords", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.diminished,
          ChordInversion.root,
        );
        final notes = chord.notes;

        final firstInterval = (notes[1].index - notes[0].index + 12) % 12;
        final secondInterval = (notes[2].index - notes[1].index + 12) % 12;

        expect(firstInterval, equals(3)); // Minor third
        expect(secondInterval, equals(3)); // Minor third
      });

      test("should have correct intervals for augmented chords", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.augmented,
          ChordInversion.root,
        );
        final notes = chord.notes;

        final firstInterval = (notes[1].index - notes[0].index + 12) % 12;
        final secondInterval = (notes[2].index - notes[1].index + 12) % 12;

        expect(firstInterval, equals(4)); // Major third
        expect(secondInterval, equals(4)); // Major third
      });
    });

    group("Additional comprehensive coverage", () {
      // Helper to determine expected note count based on chord type
      int expectedNoteCount(ChordType type) {
        switch (type) {
          case ChordType.major:
          case ChordType.minor:
          case ChordType.diminished:
          case ChordType.augmented:
            return 3; // Triads
          case ChordType.major7:
          case ChordType.dominant7:
          case ChordType.minor7:
          case ChordType.halfDiminished7:
          case ChordType.diminished7:
          case ChordType.minorMajor7:
          case ChordType.augmented7:
            return 4; // Seventh chords
        }
      }

      test("should handle all combinations of notes, types, and inversions", () {
        var totalCombinations = 0;

        for (final note in MusicalNote.values) {
          for (final type in ChordType.values) {
            // Skip third inversion for triads (only valid for seventh chords)
            final inversions =
                type == ChordType.major ||
                    type == ChordType.minor ||
                    type == ChordType.diminished ||
                    type == ChordType.augmented
                ? [
                    ChordInversion.root,
                    ChordInversion.first,
                    ChordInversion.second,
                  ]
                : ChordInversion.values;

            for (final inversion in inversions) {
              final chord = ChordDefinitions.getChord(note, type, inversion);
              final expectedNotes = expectedNoteCount(type);

              // Basic validations
              expect(chord.rootNote, equals(note));
              expect(chord.type, equals(type));
              expect(chord.inversion, equals(inversion));
              expect(chord.notes, hasLength(expectedNotes));
              expect(chord.name, isNotEmpty);

              // MIDI notes should be valid
              final midiNotes = chord.getMidiNotes(4);
              expect(midiNotes, hasLength(expectedNotes));
              for (final midi in midiNotes) {
                expect(midi, greaterThanOrEqualTo(0));
                expect(midi, lessThanOrEqualTo(127));
              }

              // MIDI notes should be in ascending order
              for (var i = 0; i < midiNotes.length - 1; i++) {
                expect(
                  midiNotes[i],
                  lessThan(midiNotes[i + 1]),
                  reason:
                      "MIDI notes should be ascending for $note $type ($inversion)",
                );
              }

              totalCombinations++;
            }
          }
        }

        // Ensure we tested all expected combinations
        // Triads: 12 notes × 4 types × 3 inversions = 144
        // Seventh chords: 12 notes × 7 types × 4 inversions = 336
        // Total: 144 + 336 = 480
        expect(totalCombinations, equals(480));
      });

      test("should generate correct MIDI notes across different octaves", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );

        for (var octave = 0; octave <= 8; octave++) {
          final midiNotes = chord.getMidiNotes(octave);
          expect(midiNotes, hasLength(3));

          // Validate ascending order
          expect(midiNotes[0], lessThan(midiNotes[1]));
          expect(midiNotes[1], lessThan(midiNotes[2]));

          // Validate reasonable range (within 2 octaves)
          expect(midiNotes[2] - midiNotes[0], lessThanOrEqualTo(24));
        }
      });

      test("should handle edge case scales and chord progressions", () {
        // Test all key/scale combinations to ensure getChordsInKey doesn't break
        for (final key in Key.values) {
          for (final scaleType in ScaleType.values) {
            final chordTypes = ChordDefinitions.getChordsInKey(key, scaleType);
            expect(chordTypes, hasLength(7));

            // Each chord type should be valid
            for (final chordType in chordTypes) {
              expect(ChordType.values, contains(chordType));
            }

            // Generate progression and validate
            final progression = ChordDefinitions.getKeyTriadProgression(
              key,
              scaleType,
            );
            expect(progression, hasLength(21)); // 7 chords × 3 inversions

            // Generate MIDI sequence and validate
            final midiSequence =
                ChordDefinitions.getChordProgressionMidiSequence(
                  key,
                  scaleType,
                  4,
                );
            expect(midiSequence, hasLength(63)); // 21 chords × 3 notes each

            // All MIDI notes should be valid
            for (final midi in midiSequence) {
              expect(midi, greaterThanOrEqualTo(0));
              expect(midi, lessThanOrEqualTo(127));
            }
          }
        }
      });

      test(
        "should handle chord inversions with proper MIDI voicing across all octaves",
        () {
          for (final note in MusicalNote.values) {
            for (final type in ChordType.values) {
              final expectedNotes = expectedNoteCount(type);

              // Skip third inversion for triads (only valid for seventh chords)
              final inversions =
                  type == ChordType.major ||
                      type == ChordType.minor ||
                      type == ChordType.diminished ||
                      type == ChordType.augmented
                  ? [
                      ChordInversion.root,
                      ChordInversion.first,
                      ChordInversion.second,
                    ]
                  : ChordInversion.values;

              for (var octave = 1; octave <= 7; octave++) {
                for (final inversion in inversions) {
                  final chord = ChordDefinitions.getChord(
                    note,
                    type,
                    inversion,
                  );
                  final midiNotes = chord.getMidiNotes(octave);

                  // Verify correct number of notes
                  expect(
                    midiNotes.length,
                    equals(expectedNotes),
                    reason:
                        "Should have $expectedNotes notes for ${type.name} ${inversion.name}",
                  );

                  // All notes should be ascending
                  for (var i = 0; i < midiNotes.length - 1; i++) {
                    expect(
                      midiNotes[i],
                      lessThan(midiNotes[i + 1]),
                      reason:
                          "Notes should be ascending for ${note.name} ${type.name} ${inversion.name} in octave $octave",
                    );
                  }

                  // Should span reasonable range (within 2 octaves)
                  expect(
                    midiNotes.last - midiNotes.first,
                    lessThanOrEqualTo(24),
                    reason:
                        "Chord span should be ≤24 semitones for ${note.name} ${type.name} ${inversion.name}",
                  );
                }
              }
            }
          }
        },
      );
    });

    group("Hand selection for chords", () {
      test("should generate left hand with full triad one octave lower", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );
        final leftHandNotes = chord.getMidiNotesForHand(4, HandSelection.left);

        // Left hand should return full triad one octave lower
        expect(leftHandNotes, hasLength(3));
        // C major root position one octave lower: C3, E3, G3
        expect(leftHandNotes, equals([48, 52, 55]));
      });

      test("should generate right hand with full triad", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );
        final rightHandNotes = chord.getMidiNotesForHand(
          4,
          HandSelection.right,
        );
        final regularMidi = chord.getMidiNotes(4);

        // Right hand should return full triad at specified octave
        expect(rightHandNotes, equals(regularMidi));
        // C major root position: C4, E4, G4
        expect(rightHandNotes, equals([60, 64, 67]));
      });

      test("should generate both hands with full triads in each hand", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.root,
        );
        final bothHandsNotes = chord.getMidiNotesForHand(4, HandSelection.both);
        final regularMidi = chord.getMidiNotes(4);

        // Both hands should have 2x the notes (full triad in each hand)
        expect(bothHandsNotes.length, equals(regularMidi.length * 2));

        // Should be: all notes -12, then all notes
        final expected = <int>[];
        expected.addAll(regularMidi.map((note) => note - 12));
        expected.addAll(regularMidi);
        expect(bothHandsNotes, equals(expected));

        // Both hands C major: C3,E3,G3,C4,E4,G4
        expect(bothHandsNotes, equals([48, 52, 55, 60, 64, 67]));
      });

      test("should handle chord inversions for all hand selections", () {
        final inversions = [
          ChordInversion.root,
          ChordInversion.first,
          ChordInversion.second,
        ];

        for (final inversion in inversions) {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major,
            inversion,
          );

          // Test all hand selections
          for (final hand in HandSelection.values) {
            final notes = chord.getMidiNotesForHand(4, hand);
            expect(
              notes,
              isNotEmpty,
              reason: "$inversion with $hand should not be empty",
            );

            // Verify hand-specific behavior
            if (hand == HandSelection.left) {
              // Left hand should have full triad one octave lower (3 notes)
              expect(notes.length, equals(3));
            } else if (hand == HandSelection.right) {
              // Right hand should have full triad (3 notes)
              final regularMidi = chord.getMidiNotes(4);
              expect(notes, equals(regularMidi));
            } else {
              // Both hands: full triad -12 + full triad
              final regularMidi = chord.getMidiNotes(4);
              expect(notes.length, equals(regularMidi.length * 2));
            }
          }
        }
      });

      test("should handle all chord types with hand selection", () {
        final types = [
          ChordType.major,
          ChordType.minor,
          ChordType.diminished,
          ChordType.augmented,
        ];

        for (final type in types) {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            type,
            ChordInversion.root,
          );

          // Test both hands mode
          final bothHandsNotes = chord.getMidiNotesForHand(
            4,
            HandSelection.both,
          );
          final regularMidi = chord.getMidiNotes(4);

          // Both hands should have 2x the regular notes
          expect(
            bothHandsNotes.length,
            equals(regularMidi.length * 2),
            reason: "$type both hands should have double the notes",
          );

          // Verify structure: all notes -12, then all notes
          for (var i = 0; i < regularMidi.length; i++) {
            expect(
              bothHandsNotes[i],
              equals(regularMidi[i] - 12),
              reason: "$type left hand notes should be 12 semitones lower",
            );
            expect(
              bothHandsNotes[i + regularMidi.length],
              equals(regularMidi[i]),
              reason: "$type right hand notes should match regular MIDI",
            );
          }
        }
      });

      test("should handle all 12 root notes with hand selection", () {
        for (final rootNote in MusicalNote.values) {
          final chord = ChordDefinitions.getChord(
            rootNote,
            ChordType.major,
            ChordInversion.root,
          );

          final bothHandsNotes = chord.getMidiNotesForHand(
            4,
            HandSelection.both,
          );
          final regularMidi = chord.getMidiNotes(4);

          // Should have 2x the regular notes
          expect(
            bothHandsNotes.length,
            equals(regularMidi.length * 2),
            reason: "$rootNote major should have double the notes",
          );

          // Verify structure: all notes -12, then all notes
          for (var i = 0; i < regularMidi.length; i++) {
            expect(
              bothHandsNotes[i],
              equals(regularMidi[i] - 12),
              reason: "$rootNote left hand should be 12 semitones lower",
            );
            expect(
              bothHandsNotes[i + regularMidi.length],
              equals(regularMidi[i]),
              reason: "$rootNote right hand should match regular MIDI",
            );
          }
        }
      });

      test("should handle first inversion with both hands", () {
        final chord = ChordDefinitions.getChord(
          MusicalNote.c,
          ChordType.major,
          ChordInversion.first,
        );
        final bothHandsNotes = chord.getMidiNotesForHand(4, HandSelection.both);
        final regularMidi = chord.getMidiNotes(4);

        // Should be: all notes -12, then all notes
        expect(bothHandsNotes.length, equals(regularMidi.length * 2));

        // Verify specific MIDI values for first inversion
        // C major first inversion regular: E4,G4,C5 -> [64, 67, 72]
        // Left hand (all -12): E3,G3,C4 -> [52, 55, 60]
        // Combined: [52, 55, 60, 64, 67, 72]
        expect(bothHandsNotes, equals([52, 55, 60, 64, 67, 72]));
      });
    });

    group("Seventh chords", () {
      group("Major 7th chords", () {
        test("should create C Major 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.major7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("Cmaj7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.b,
            ]),
          );
        });

        test("should create all inversions of C Major 7th chord", () {
          // Root position: C-E-G-B
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.b,
            ]),
          );
          expect(root.name, equals("Cmaj7"));

          // 1st inversion: E-G-B-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.b,
              MusicalNote.c,
            ]),
          );
          expect(first.name, equals("Cmaj7 (1st inv)"));

          // 2nd inversion: G-B-C-E
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.g,
              MusicalNote.b,
              MusicalNote.c,
              MusicalNote.e,
            ]),
          );
          expect(second.name, equals("Cmaj7 (2nd inv)"));

          // 3rd inversion: B-C-E-G
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.b,
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
            ]),
          );
          expect(third.name, equals("Cmaj7 (3rd inv)"));
        });
      });

      group("Dominant 7th chords", () {
        test("should create C Dominant 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.dominant7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.dominant7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("C7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.aSharp,
            ]),
          );
        });

        test("should create all inversions of C Dominant 7th chord", () {
          // Root position: C-E-G-Bb
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.dominant7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.aSharp,
            ]),
          );

          // 1st inversion: E-G-Bb-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.dominant7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.e,
              MusicalNote.g,
              MusicalNote.aSharp,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: G-Bb-C-E
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.dominant7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.g,
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.e,
            ]),
          );

          // 3rd inversion: Bb-C-E-G
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.dominant7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.g,
            ]),
          );
        });
      });

      group("Minor 7th chords", () {
        test("should create C Minor 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minor7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.minor7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("Cm7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.aSharp,
            ]),
          );
        });

        test("should create all inversions of C Minor 7th chord", () {
          // Root position: C-Eb-G-Bb
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minor7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.aSharp,
            ]),
          );

          // 1st inversion: Eb-G-Bb-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minor7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.aSharp,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: G-Bb-C-Eb
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minor7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.g,
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.dSharp,
            ]),
          );

          // 3rd inversion: Bb-C-Eb-G
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minor7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
            ]),
          );
        });
      });

      group("Half Diminished 7th chords", () {
        test("should create C Half Diminished 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.halfDiminished7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.halfDiminished7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("Cø7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.aSharp,
            ]),
          );
        });

        test("should create all inversions of C Half Diminished 7th chord", () {
          // Root position: C-Eb-Gb-Bb
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.halfDiminished7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.aSharp,
            ]),
          );

          // 1st inversion: Eb-Gb-Bb-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.halfDiminished7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.aSharp,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: Gb-Bb-C-Eb
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.halfDiminished7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.fSharp,
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.dSharp,
            ]),
          );

          // 3rd inversion: Bb-C-Eb-Gb
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.halfDiminished7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
            ]),
          );
        });
      });

      group("Diminished 7th chords", () {
        test("should create C Diminished 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.diminished7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.diminished7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("C°7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.a,
            ]),
          );
        });

        test("should create all inversions of C Diminished 7th chord", () {
          // Root position: C-Eb-Gb-A
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.diminished7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.a,
            ]),
          );

          // 1st inversion: Eb-Gb-A-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.diminished7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.dSharp,
              MusicalNote.fSharp,
              MusicalNote.a,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: Gb-A-C-Eb
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.diminished7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.fSharp,
              MusicalNote.a,
              MusicalNote.c,
              MusicalNote.dSharp,
            ]),
          );

          // 3rd inversion: A-C-Eb-Gb
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.diminished7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.a,
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.fSharp,
            ]),
          );
        });
      });

      group("Minor/Major 7th chords", () {
        test("should create C Minor/Major 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minorMajor7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.minorMajor7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("Cm(maj7)"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.b,
            ]),
          );
        });

        test("should create all inversions of C Minor/Major 7th chord", () {
          // Root position: C-Eb-G-B
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minorMajor7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.b,
            ]),
          );

          // 1st inversion: Eb-G-B-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minorMajor7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.dSharp,
              MusicalNote.g,
              MusicalNote.b,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: G-B-C-Eb
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minorMajor7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.g,
              MusicalNote.b,
              MusicalNote.c,
              MusicalNote.dSharp,
            ]),
          );

          // 3rd inversion: B-C-Eb-G
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.minorMajor7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.b,
              MusicalNote.c,
              MusicalNote.dSharp,
              MusicalNote.g,
            ]),
          );
        });
      });

      group("Augmented 7th chords", () {
        test("should create C Augmented 7th chord correctly", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.augmented7,
            ChordInversion.root,
          );

          expect(chord.rootNote, equals(MusicalNote.c));
          expect(chord.type, equals(ChordType.augmented7));
          expect(chord.inversion, equals(ChordInversion.root));
          expect(chord.name, equals("Caug7"));
          expect(chord.notes.length, equals(4));
          expect(
            chord.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.gSharp,
              MusicalNote.aSharp,
            ]),
          );
        });

        test("should create all inversions of C Augmented 7th chord", () {
          // Root position: C-E-G#-Bb
          final root = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.augmented7,
            ChordInversion.root,
          );
          expect(
            root.notes,
            equals([
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.gSharp,
              MusicalNote.aSharp,
            ]),
          );

          // 1st inversion: E-G#-Bb-C
          final first = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.augmented7,
            ChordInversion.first,
          );
          expect(
            first.notes,
            equals([
              MusicalNote.e,
              MusicalNote.gSharp,
              MusicalNote.aSharp,
              MusicalNote.c,
            ]),
          );

          // 2nd inversion: G#-Bb-C-E
          final second = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.augmented7,
            ChordInversion.second,
          );
          expect(
            second.notes,
            equals([
              MusicalNote.gSharp,
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.e,
            ]),
          );

          // 3rd inversion: Bb-C-E-G#
          final third = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.augmented7,
            ChordInversion.third,
          );
          expect(
            third.notes,
            equals([
              MusicalNote.aSharp,
              MusicalNote.c,
              MusicalNote.e,
              MusicalNote.gSharp,
            ]),
          );
        });
      });

      group("Seventh chord MIDI generation", () {
        test("should generate correct MIDI notes for seventh chords", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.root,
          );
          final midiNotes = chord.getMidiNotes(4);

          // C4=60, E4=64, G4=67, B4=71
          expect(midiNotes, equals([60, 64, 67, 71]));
          expect(midiNotes.length, equals(4));
        });

        test(
          "should generate MIDI notes in ascending order for all inversions",
          () {
            for (final inversion in ChordInversion.values) {
              final chord = ChordDefinitions.getChord(
                MusicalNote.c,
                ChordType.dominant7,
                inversion,
              );
              final midiNotes = chord.getMidiNotes(4);

              // Verify ascending order
              for (int i = 0; i < midiNotes.length - 1; i++) {
                expect(
                  midiNotes[i] < midiNotes[i + 1],
                  isTrue,
                  reason: "MIDI notes should be ascending for $inversion",
                );
              }
            }
          },
        );

        test("should handle both hands with seventh chords (8 total notes)", () {
          final chord = ChordDefinitions.getChord(
            MusicalNote.c,
            ChordType.major7,
            ChordInversion.root,
          );
          final bothHandsNotes = chord.getMidiNotesForHand(
            4,
            HandSelection.both,
          );
          final regularMidi = chord.getMidiNotes(4);

          // Both hands: 4 notes in left (octave down) + 4 notes in right = 8 total
          expect(bothHandsNotes.length, equals(8));
          expect(bothHandsNotes.length, equals(regularMidi.length * 2));

          // Verify first 4 notes are octave down, last 4 are regular
          // C4maj7 regular: [60, 64, 67, 71]
          // Left hand: [48, 52, 55, 59]
          // Combined: [48, 52, 55, 59, 60, 64, 67, 71]
          expect(bothHandsNotes, equals([48, 52, 55, 59, 60, 64, 67, 71]));
        });
      });

      group("Diatonic seventh chord determination", () {
        test("should return correct seventh chord types for C major scale", () {
          final seventhChords = ChordDefinitions.getSeventhChordsInKey(
            Key.c,
            ScaleType.major,
          );

          // I=maj7, ii=m7, iii=m7, IV=maj7, V=7, vi=m7, vii=ø7
          expect(seventhChords.length, equals(7));
          expect(seventhChords[0], equals(ChordType.major7));
          expect(seventhChords[1], equals(ChordType.minor7));
          expect(seventhChords[2], equals(ChordType.minor7));
          expect(seventhChords[3], equals(ChordType.major7));
          expect(seventhChords[4], equals(ChordType.dominant7));
          expect(seventhChords[5], equals(ChordType.minor7));
          expect(seventhChords[6], equals(ChordType.halfDiminished7));
        });

        test("should return correct seventh chord types for A minor scale", () {
          final seventhChords = ChordDefinitions.getSeventhChordsInKey(
            Key.a,
            ScaleType.minor,
          );

          // i=m7, ii=ø7, III=maj7, iv=m7, v=m7, VI=maj7, VII=7
          expect(seventhChords.length, equals(7));
          expect(seventhChords[0], equals(ChordType.minor7));
          expect(seventhChords[1], equals(ChordType.halfDiminished7));
          expect(seventhChords[2], equals(ChordType.major7));
          expect(seventhChords[3], equals(ChordType.minor7));
          expect(seventhChords[4], equals(ChordType.minor7));
          expect(seventhChords[5], equals(ChordType.major7));
          expect(seventhChords[6], equals(ChordType.dominant7));
        });
      });

      group("Seventh chord progressions", () {
        test("should generate smooth seventh chord progression in C major", () {
          final progression =
              ChordDefinitions.getSmoothKeySeventhChordProgression(
                Key.c,
                ScaleType.major,
              );

          // Should get 7 scale degrees × 6 chords per degree (root→1st→2nd→3rd→2nd→1st) = 42 total
          expect(progression.length, equals(42));

          // Verify first 6 chords are Cmaj7 with proper inversion sequence
          expect(progression[0].type, equals(ChordType.major7)); // Cmaj7 root
          expect(progression[0].inversion, equals(ChordInversion.root));
          expect(progression[1].type, equals(ChordType.major7)); // Cmaj7 1st
          expect(progression[1].inversion, equals(ChordInversion.first));
          expect(progression[2].type, equals(ChordType.major7)); // Cmaj7 2nd
          expect(progression[2].inversion, equals(ChordInversion.second));
          expect(progression[3].type, equals(ChordType.major7)); // Cmaj7 3rd
          expect(progression[3].inversion, equals(ChordInversion.third));
          expect(progression[4].type, equals(ChordType.major7)); // Cmaj7 2nd
          expect(progression[4].inversion, equals(ChordInversion.second));
          expect(progression[5].type, equals(ChordType.major7)); // Cmaj7 1st
          expect(progression[5].inversion, equals(ChordInversion.first));

          // Verify next 6 chords are Dm7
          expect(progression[6].type, equals(ChordType.minor7)); // Dm7 root
          expect(progression[7].type, equals(ChordType.minor7)); // Dm7 1st
        });

        test(
          "should generate seventh chord progression with all 4-note chords",
          () {
            final progression =
                ChordDefinitions.getSmoothKeySeventhChordProgression(
                  Key.c,
                  ScaleType.major,
                );

            // Every chord should have 4 notes
            for (final chord in progression) {
              expect(chord.notes.length, equals(4));
            }
          },
        );
      });
    });
  });
}
