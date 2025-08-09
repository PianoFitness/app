import "package:flutter_test/flutter_test.dart";
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
      test("should generate chords for all chord types and keys", () {
        for (final note in MusicalNote.values) {
          for (final type in ChordType.values) {
            for (final inversion in ChordInversion.values) {
              final chord = ChordDefinitions.getChord(note, type, inversion);

              expect(chord.rootNote, equals(note));
              expect(chord.type, equals(type));
              expect(chord.inversion, equals(inversion));
              expect(chord.notes.length, equals(3));
              expect(chord.name, isNotEmpty);

              // Test MIDI generation
              final midiNotes = chord.getMidiNotes(4);
              expect(midiNotes.length, equals(3));

              // MIDI notes should be in ascending order for proper voicing
              expect(midiNotes[0], lessThan(midiNotes[1]));
              expect(midiNotes[1], lessThan(midiNotes[2]));
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
      test(
        "should handle all combinations of notes, types, and inversions",
        () {
          var totalCombinations = 0;

          for (final note in MusicalNote.values) {
            for (final type in ChordType.values) {
              for (final inversion in ChordInversion.values) {
                final chord = ChordDefinitions.getChord(note, type, inversion);

                // Basic validations
                expect(chord.rootNote, equals(note));
                expect(chord.type, equals(type));
                expect(chord.inversion, equals(inversion));
                expect(chord.notes, hasLength(3));
                expect(chord.name, isNotEmpty);

                // MIDI notes should be valid
                final midiNotes = chord.getMidiNotes(4);
                expect(midiNotes, hasLength(3));
                for (final midi in midiNotes) {
                  expect(midi, greaterThanOrEqualTo(0));
                  expect(midi, lessThanOrEqualTo(127));
                }

                // MIDI notes should be in ascending order
                expect(midiNotes[0], lessThan(midiNotes[1]));
                expect(midiNotes[1], lessThan(midiNotes[2]));

                totalCombinations++;
              }
            }
          }

          // Ensure we tested all expected combinations
          expect(
            totalCombinations,
            equals(12 * 4 * 3),
          ); // 12 notes × 4 types × 3 inversions = 144
        },
      );

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
              final root = ChordDefinitions.getChord(
                note,
                type,
                ChordInversion.root,
              );
              final first = ChordDefinitions.getChord(
                note,
                type,
                ChordInversion.first,
              );
              final second = ChordDefinitions.getChord(
                note,
                type,
                ChordInversion.second,
              );

              for (var octave = 1; octave <= 7; octave++) {
                final rootMidi = root.getMidiNotes(octave);
                final firstMidi = first.getMidiNotes(octave);
                final secondMidi = second.getMidiNotes(octave);

                // All should be ascending
                expect(rootMidi[0], lessThan(rootMidi[1]));
                expect(rootMidi[1], lessThan(rootMidi[2]));
                expect(firstMidi[0], lessThan(firstMidi[1]));
                expect(firstMidi[1], lessThan(firstMidi[2]));
                expect(secondMidi[0], lessThan(secondMidi[1]));
                expect(secondMidi[1], lessThan(secondMidi[2]));

                // Should span reasonable range
                expect(rootMidi[2] - rootMidi[0], lessThanOrEqualTo(24));
                expect(firstMidi[2] - firstMidi[0], lessThanOrEqualTo(24));
                expect(secondMidi[2] - secondMidi[0], lessThanOrEqualTo(24));
              }
            }
          }
        },
      );
    });
  });
}
