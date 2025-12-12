import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

void main() {
  group("ArpeggioDefinitions", () {
    group("Basic arpeggio generation", () {
      test("should create C Major arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );

        expect(arpeggio.rootNote, equals(MusicalNote.c));
        expect(arpeggio.type, equals(ArpeggioType.major));
        expect(arpeggio.octaves, equals(ArpeggioOctaves.one));
        expect(arpeggio.name, equals("C Major (1 Octave)"));
        expect(arpeggio.intervals, equals([0, 4, 7, 12]));
      });

      test("should create C Minor arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.minor,
          ArpeggioOctaves.two,
        );

        expect(arpeggio.rootNote, equals(MusicalNote.c));
        expect(arpeggio.type, equals(ArpeggioType.minor));
        expect(arpeggio.octaves, equals(ArpeggioOctaves.two));
        expect(arpeggio.name, equals("C Minor (2 Octaves)"));
        expect(arpeggio.intervals, equals([0, 3, 7, 12]));
      });

      test("should create F# Diminished arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.fSharp,
          ArpeggioType.diminished,
          ArpeggioOctaves.one,
        );

        expect(arpeggio.rootNote, equals(MusicalNote.fSharp));
        expect(arpeggio.type, equals(ArpeggioType.diminished));
        expect(arpeggio.name, equals("F# Diminished (1 Octave)"));
        expect(arpeggio.intervals, equals([0, 3, 6, 12]));
      });

      test("should create G Augmented arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.g,
          ArpeggioType.augmented,
          ArpeggioOctaves.two,
        );

        expect(arpeggio.rootNote, equals(MusicalNote.g));
        expect(arpeggio.type, equals(ArpeggioType.augmented));
        expect(arpeggio.name, equals("G Augmented (2 Octaves)"));
        expect(arpeggio.intervals, equals([0, 4, 8, 12]));
      });
    });

    group("7th chord arpeggios", () {
      test("should create Dominant 7th arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.dominant7,
          ArpeggioOctaves.one,
        );

        expect(arpeggio.intervals, equals([0, 4, 7, 10, 12]));
        expect(arpeggio.name, equals("C Dominant 7th (1 Octave)"));
      });

      test("should create Minor 7th arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.d,
          ArpeggioType.minor7,
          ArpeggioOctaves.two,
        );

        expect(arpeggio.intervals, equals([0, 3, 7, 10, 12]));
        expect(arpeggio.name, equals("D Minor 7th (2 Octaves)"));
      });

      test("should create Major 7th arpeggio correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.f,
          ArpeggioType.major7,
          ArpeggioOctaves.one,
        );

        expect(arpeggio.intervals, equals([0, 4, 7, 11, 12]));
        expect(arpeggio.name, equals("F Major 7th (1 Octave)"));
      });
    });

    group("Arpeggio note generation", () {
      test("should generate correct notes for C Major arpeggio", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );

        final notes = arpeggio.getNotes();
        expect(
          notes,
          equals([
            MusicalNote.c, // 0 semitones
            MusicalNote.e, // 4 semitones
            MusicalNote.g, // 7 semitones
            MusicalNote.c, // 12 semitones (octave)
          ]),
        );
      });

      test("should generate correct notes for F# Minor arpeggio", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.fSharp,
          ArpeggioType.minor,
          ArpeggioOctaves.one,
        );

        final notes = arpeggio.getNotes();
        expect(
          notes,
          equals([
            MusicalNote.fSharp, // 0 semitones
            MusicalNote.a, // 3 semitones
            MusicalNote.cSharp, // 7 semitones
            MusicalNote.fSharp, // 12 semitones (octave)
          ]),
        );
      });
    });

    group("MIDI note generation", () {
      test(
        "should generate correct MIDI notes for C Major arpeggio in octave 4",
        () {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            ArpeggioType.major,
            ArpeggioOctaves.one,
          );

          final midiNotes = arpeggio.getMidiNotes(4);
          expect(midiNotes, equals([60, 64, 67, 72])); // C4, E4, G4, C5
        },
      );

      test(
        "should generate correct MIDI notes for D Minor arpeggio in octave 3",
        () {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.d,
            ArpeggioType.minor,
            ArpeggioOctaves.one,
          );

          final midiNotes = arpeggio.getMidiNotes(3);
          expect(midiNotes, equals([50, 53, 57, 62])); // D3, F3, A3, D4
        },
      );

      test("should handle octave wrapping correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.a,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );

        final midiNotes = arpeggio.getMidiNotes(4);
        // A4=69, C#5=73, E5=76, A5=81
        expect(midiNotes, equals([69, 73, 76, 81]));
      });
    });

    group("Full arpeggio sequences", () {
      test("should generate one octave sequence (up and down)", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );

        final sequence = arpeggio.getFullArpeggioSequence(4);
        // Up: C4, E4, G4, C5
        // Down: G4, E4, C4 (skip C5 to avoid duplication)
        expect(sequence, equals([60, 64, 67, 72, 67, 64, 60]));
      });

      test("should generate two octave sequence", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.two,
        );

        final sequence = arpeggio.getFullArpeggioSequence(4);
        // Should go up 2 octaves then back down
        expect(sequence.length, greaterThan(7)); // More than one octave
        expect(sequence.first, equals(60)); // Starts with C4
        expect(sequence.last, equals(60)); // Ends with C4

        // Should contain high C (C6 = 84)
        expect(sequence, contains(84));
      });

      test(
        "should generate correct C Major two octave sequence with expected MIDI notes",
        () {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            ArpeggioType.major,
            ArpeggioOctaves.two,
          );

          final sequence = arpeggio.getFullArpeggioSequence(4);

          // Expected sequence: C4, E4, G4, C5, E5, G5, C6, G5, E5, C5, G4, E4, C4
          // MIDI:              60, 64, 67, 72, 76, 79, 84, 79, 76, 72, 67, 64, 60
          final expectedSequence = [
            60,
            64,
            67,
            72,
            76,
            79,
            84,
            79,
            76,
            72,
            67,
            64,
            60,
          ];

          expect(sequence, equals(expectedSequence));
          expect(sequence.length, equals(13)); // 7 up + 6 down

          // Verify no unexpected jumps
          for (var i = 1; i < sequence.length; i++) {
            final interval = (sequence[i] - sequence[i - 1]).abs();
            expect(
              interval,
              lessThanOrEqualTo(12),
              reason:
                  "No interval should be larger than an octave between ${sequence[i - 1]} and ${sequence[i]}",
            );
          }
        },
      );

      test("should handle minor arpeggio sequences correctly", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.a,
          ArpeggioType.minor,
          ArpeggioOctaves.one,
        );

        final sequence = arpeggio.getFullArpeggioSequence(4);
        // A4=69, C5=72, E5=76, A5=81
        // Up: A4, C5, E5, A5
        // Down: E5, C5, A4
        expect(sequence, equals([69, 72, 76, 81, 76, 72, 69]));
      });

      test(
        "should generate correct A Minor two octave sequence without large jumps",
        () {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.a,
            ArpeggioType.minor,
            ArpeggioOctaves.two,
          );

          final sequence = arpeggio.getFullArpeggioSequence(4);

          // Expected: A4, C5, E5, A5, C6, E6, A6, E6, C6, A5, E5, C5, A4
          // MIDI:     69, 72, 76, 81, 84, 88, 93, 88, 84, 81, 76, 72, 69
          final expectedSequence = [
            69,
            72,
            76,
            81,
            84,
            88,
            93,
            88,
            84,
            81,
            76,
            72,
            69,
          ];

          expect(sequence, equals(expectedSequence));

          // Verify no unexpected jumps (no interval larger than an octave)
          for (var i = 1; i < sequence.length; i++) {
            final interval = (sequence[i] - sequence[i - 1]).abs();
            expect(
              interval,
              lessThanOrEqualTo(12),
              reason:
                  "No interval should be larger than an octave between ${sequence[i - 1]} and ${sequence[i]}",
            );
          }
        },
      );

      test("should generate correct G Major two octave sequence", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.g,
          ArpeggioType.major,
          ArpeggioOctaves.two,
        );

        final sequence = arpeggio.getFullArpeggioSequence(4);

        // Expected: G4, B4, D5, G5, B5, D6, G6, D6, B5, G5, D5, B4, G4
        // MIDI:     67, 71, 74, 79, 83, 86, 91, 86, 83, 79, 74, 71, 67
        final expectedSequence = [
          67,
          71,
          74,
          79,
          83,
          86,
          91,
          86,
          83,
          79,
          74,
          71,
          67,
        ];

        expect(sequence, equals(expectedSequence));
        expect(sequence.length, equals(13)); // 7 up + 6 down
      });

      test(
        "should verify no large jumps in two-octave sequences (regression test)",
        () {
          // This test ensures we fixed the bug where C5 jumped to E6 instead of E5
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            ArpeggioType.major,
            ArpeggioOctaves.two,
          );

          final sequence = arpeggio.getFullArpeggioSequence(4);

          // Check specifically that after C5 (MIDI 72), the next note is E5 (MIDI 76), not E6 (MIDI 88)
          final c5Index = sequence.indexOf(72);
          expect(
            c5Index,
            greaterThan(-1),
            reason: "C5 should be in the sequence",
          );
          expect(
            sequence[c5Index + 1],
            equals(76),
            reason: "After C5, the next note should be E5 (76), not E6 (88)",
          );

          // Verify the complete ascending portion has no jumps larger than 5 semitones (perfect 4th)
          final ascendingPortion = sequence.sublist(
            0,
            7,
          ); // First 7 notes (up to C6)
          for (var i = 1; i < ascendingPortion.length; i++) {
            final interval = ascendingPortion[i] - ascendingPortion[i - 1];
            expect(
              interval,
              lessThanOrEqualTo(5),
              reason:
                  "Ascending interval from ${ascendingPortion[i - 1]} to ${ascendingPortion[i]} should not exceed a perfect 4th",
            );
          }
        },
      );
    });

    group("Common arpeggio collections", () {
      test("should return 4 common arpeggios for a root note", () {
        final arpeggios = ArpeggioDefinitions.getCommonArpeggios(
          MusicalNote.g,
          ArpeggioOctaves.one,
        );

        expect(arpeggios.length, equals(4));
        expect(arpeggios[0].type, equals(ArpeggioType.major));
        expect(arpeggios[1].type, equals(ArpeggioType.minor));
        expect(arpeggios[2].type, equals(ArpeggioType.diminished));
        expect(arpeggios[3].type, equals(ArpeggioType.augmented));

        // All should have same root note and octave setting
        for (final arpeggio in arpeggios) {
          expect(arpeggio.rootNote, equals(MusicalNote.g));
          expect(arpeggio.octaves, equals(ArpeggioOctaves.one));
        }
      });

      test("should return 7 extended arpeggios for a root note", () {
        final arpeggios = ArpeggioDefinitions.getExtendedArpeggios(
          MusicalNote.e,
          ArpeggioOctaves.two,
        );

        expect(arpeggios.length, equals(7));

        final types = arpeggios.map((a) => a.type).toList();
        expect(types, contains(ArpeggioType.major));
        expect(types, contains(ArpeggioType.minor));
        expect(types, contains(ArpeggioType.diminished));
        expect(types, contains(ArpeggioType.augmented));
        expect(types, contains(ArpeggioType.dominant7));
        expect(types, contains(ArpeggioType.minor7));
        expect(types, contains(ArpeggioType.major7));
      });

      test("should return C Major arpeggios in both octave options", () {
        final arpeggios = ArpeggioDefinitions.getCMajorArpeggios();

        expect(arpeggios.length, equals(2));
        expect(arpeggios[0].rootNote, equals(MusicalNote.c));
        expect(arpeggios[0].type, equals(ArpeggioType.major));
        expect(arpeggios[0].octaves, equals(ArpeggioOctaves.one));

        expect(arpeggios[1].rootNote, equals(MusicalNote.c));
        expect(arpeggios[1].type, equals(ArpeggioType.major));
        expect(arpeggios[1].octaves, equals(ArpeggioOctaves.two));
      });
    });

    group("Edge cases and comprehensive coverage", () {
      test("should handle all root notes correctly", () {
        for (final note in MusicalNote.values) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            note,
            ArpeggioType.major,
            ArpeggioOctaves.one,
          );

          expect(arpeggio.rootNote, equals(note));
          expect(arpeggio.getNotes().isNotEmpty, isTrue);
          expect(arpeggio.getMidiNotes(4).isNotEmpty, isTrue);
        }
      });

      test("should handle all arpeggio types correctly", () {
        for (final type in ArpeggioType.values) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            type,
            ArpeggioOctaves.one,
          );

          expect(arpeggio.type, equals(type));
          expect(arpeggio.intervals.isNotEmpty, isTrue);
          expect(arpeggio.name.isNotEmpty, isTrue);
        }
      });

      test("should handle both octave options correctly", () {
        for (final octaves in ArpeggioOctaves.values) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            ArpeggioType.major,
            octaves,
          );

          expect(arpeggio.octaves, equals(octaves));

          final sequence = arpeggio.getFullArpeggioSequence(4);
          if (octaves == ArpeggioOctaves.one) {
            expect(sequence.length, equals(7)); // 4 up + 3 down
          } else {
            expect(sequence.length, greaterThan(7)); // 2 octaves worth
          }
        }
      });

      test("should generate consistent results across multiple calls", () {
        final arpeggio1 = ArpeggioDefinitions.getArpeggio(
          MusicalNote.d,
          ArpeggioType.minor,
          ArpeggioOctaves.two,
        );
        final arpeggio2 = ArpeggioDefinitions.getArpeggio(
          MusicalNote.d,
          ArpeggioType.minor,
          ArpeggioOctaves.two,
        );

        expect(arpeggio1.intervals, equals(arpeggio2.intervals));
        expect(arpeggio1.getNotes(), equals(arpeggio2.getNotes()));
        expect(arpeggio1.getMidiNotes(4), equals(arpeggio2.getMidiNotes(4)));
        expect(
          arpeggio1.getFullArpeggioSequence(4),
          equals(arpeggio2.getFullArpeggioSequence(4)),
        );
      });

      test("should handle extreme octave ranges", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );

        // Test low octave
        final lowMidi = arpeggio.getMidiNotes(1);
        expect(lowMidi.every((note) => note >= 0), isTrue);

        // Test high octave (but not too high to avoid MIDI limit issues)
        final highMidi = arpeggio.getMidiNotes(7);
        expect(highMidi.every((note) => note <= 127), isTrue);
      });
    });

    group("All chromatic root notes functionality", () {
      test(
        "should generate correct arpeggios for all 12 chromatic root notes",
        () {
          final testCases = [
            {"note": MusicalNote.c, "name": "C"},
            {"note": MusicalNote.cSharp, "name": "C#"},
            {"note": MusicalNote.d, "name": "D"},
            {"note": MusicalNote.dSharp, "name": "D#"},
            {"note": MusicalNote.e, "name": "E"},
            {"note": MusicalNote.f, "name": "F"},
            {"note": MusicalNote.fSharp, "name": "F#"},
            {"note": MusicalNote.g, "name": "G"},
            {"note": MusicalNote.gSharp, "name": "G#"},
            {"note": MusicalNote.a, "name": "A"},
            {"note": MusicalNote.aSharp, "name": "A#"},
            {"note": MusicalNote.b, "name": "B"},
          ];

          for (final testCase in testCases) {
            final note = testCase["note"]! as MusicalNote;
            final name = testCase["name"]! as String;

            final arpeggio = ArpeggioDefinitions.getArpeggio(
              note,
              ArpeggioType.major,
              ArpeggioOctaves.one,
            );

            expect(
              arpeggio.rootNote,
              equals(note),
              reason: "$name major arpeggio should have correct root note",
            );
            expect(
              arpeggio.name,
              contains(name),
              reason: "$name major arpeggio should have correct name",
            );

            final sequence = arpeggio.getFullArpeggioSequence(4);
            expect(
              sequence.isNotEmpty,
              isTrue,
              reason: "$name major arpeggio should generate notes",
            );
            expect(
              sequence.length,
              equals(7),
              reason:
                  "$name major arpeggio should have 7 notes (4 up + 3 down)",
            );
          }
        },
      );

      test("should generate all 7th chord arpeggio types correctly", () {
        final seventhChordTypes = [
          ArpeggioType.dominant7,
          ArpeggioType.minor7,
          ArpeggioType.major7,
        ];

        for (final type in seventhChordTypes) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            type,
            ArpeggioOctaves.one,
          );

          expect(
            arpeggio.intervals.length,
            equals(5),
            reason: "7th chord should have 5 intervals (including octave)",
          );

          final sequence = arpeggio.getFullArpeggioSequence(4);
          expect(
            sequence.length,
            equals(9),
            reason: "7th chord arpeggio should have 9 notes (5 up + 4 down)",
          );

          // All 7th chords should contain the 7th interval
          expect(
            arpeggio.intervals,
            contains(anyOf(10, 11)),
            reason: "7th chord should contain a 7th interval",
          );
        }
      });

      test(
        "should work with different root notes and arpeggio types combinations",
        () {
          final combinations = [
            {
              "root": MusicalNote.fSharp,
              "type": ArpeggioType.minor,
              "expected_name": "F# Minor",
            },
            {
              "root": MusicalNote.aSharp,
              "type": ArpeggioType.diminished,
              "expected_name": "A# Diminished",
            },
            {
              "root": MusicalNote.dSharp,
              "type": ArpeggioType.augmented,
              "expected_name": "D# Augmented",
            },
            {
              "root": MusicalNote.g,
              "type": ArpeggioType.dominant7,
              "expected_name": "G Dominant 7th",
            },
            {
              "root": MusicalNote.b,
              "type": ArpeggioType.major7,
              "expected_name": "B Major 7th",
            },
          ];

          for (final combo in combinations) {
            final root = combo["root"]! as MusicalNote;
            final type = combo["type"]! as ArpeggioType;
            final expectedName = combo["expected_name"]! as String;

            final arpeggio = ArpeggioDefinitions.getArpeggio(
              root,
              type,
              ArpeggioOctaves.one,
            );

            expect(
              arpeggio.name,
              contains(expectedName.split(" ")[0]),
              reason: "Should contain root note name",
            );
            expect(
              arpeggio.rootNote,
              equals(root),
              reason: "Should have correct root note",
            );
            expect(
              arpeggio.type,
              equals(type),
              reason: "Should have correct arpeggio type",
            );

            final sequence = arpeggio.getFullArpeggioSequence(4);
            expect(
              sequence.isNotEmpty,
              isTrue,
              reason: "Should generate valid sequence",
            );
          }
        },
      );

      test("should handle all combinations with two octaves", () {
        // Test a few key combinations with two octaves to ensure no errors
        final testCombos = [
          {"root": MusicalNote.fSharp, "type": ArpeggioType.minor},
          {"root": MusicalNote.gSharp, "type": ArpeggioType.major7},
          {"root": MusicalNote.dSharp, "type": ArpeggioType.diminished},
        ];

        for (final combo in testCombos) {
          final root = combo["root"]! as MusicalNote;
          final type = combo["type"]! as ArpeggioType;

          final arpeggio = ArpeggioDefinitions.getArpeggio(
            root,
            type,
            ArpeggioOctaves.two,
          );
          final sequence = arpeggio.getFullArpeggioSequence(4);

          expect(
            sequence.isNotEmpty,
            isTrue,
            reason:
                "Two-octave ${root.name} ${type.name} should generate notes",
          );
          expect(
            sequence.length,
            greaterThan(7),
            reason: "Two-octave sequence should be longer than one octave",
          );

          // Verify no large jumps
          for (var i = 1; i < sequence.length; i++) {
            final interval = (sequence[i] - sequence[i - 1]).abs();
            expect(
              interval,
              lessThanOrEqualTo(12),
              reason:
                  "No interval should exceed an octave in ${root.name} ${type.name}",
            );
          }
        }
      });
    });

    group("Hand selection sequences", () {
      test("should generate left hand arpeggio one octave lower", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );
        final leftHandSequence = arpeggio.getHandSequence(
          4,
          HandSelection.left,
        );
        final rightHandSequence = arpeggio.getHandSequence(
          4,
          HandSelection.right,
        );

        // Left hand should be one octave (12 semitones) lower
        expect(leftHandSequence, hasLength(rightHandSequence.length));
        for (var i = 0; i < leftHandSequence.length; i++) {
          expect(leftHandSequence[i], equals(rightHandSequence[i] - 12));
        }
        // Verify it starts at C3 (MIDI 48)
        expect(leftHandSequence.first, equals(48));
      });

      test("should generate right hand arpeggio at specified octave", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );
        final rightHandSequence = arpeggio.getHandSequence(
          4,
          HandSelection.right,
        );
        final fullSequence = arpeggio.getFullArpeggioSequence(4);

        // Right hand should match the regular full sequence
        expect(rightHandSequence, equals(fullSequence));
        // Verify it starts at C4 (MIDI 60)
        expect(rightHandSequence.first, equals(60));
      });

      test("should generate both hands arpeggio with paired notes", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );
        final bothHandsSequence = arpeggio.getHandSequence(
          4,
          HandSelection.both,
        );
        final rightHandSequence = arpeggio.getHandSequence(
          4,
          HandSelection.right,
        );

        // Both hands should be 2x the length of single hand
        expect(bothHandsSequence.length, equals(rightHandSequence.length * 2));

        // Verify interleaved pattern: [L1, R1, L2, R2, ...]
        for (var i = 0; i < rightHandSequence.length; i++) {
          final leftNote = bothHandsSequence[i * 2]; // Even indices
          final rightNote = bothHandsSequence[i * 2 + 1]; // Odd indices

          // Left note should be 12 semitones lower than right note
          expect(leftNote, equals(rightNote - 12));
          // Right note should match the right hand sequence
          expect(rightNote, equals(rightHandSequence[i]));
        }
      });

      test("should handle two-octave arpeggios for both hands", () {
        final arpeggio = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.two,
        );
        final bothHandsSequence = arpeggio.getHandSequence(
          4,
          HandSelection.both,
        );

        // Should have even length (pairs of notes)
        expect(bothHandsSequence.length % 2, equals(0));

        // Verify all pairs have 12-semitone offset
        for (var i = 0; i < bothHandsSequence.length; i += 2) {
          final leftNote = bothHandsSequence[i];
          final rightNote = bothHandsSequence[i + 1];
          expect(leftNote, equals(rightNote - 12));
        }

        // Two-octave should be longer than one-octave
        final oneOctave = ArpeggioDefinitions.getArpeggio(
          MusicalNote.c,
          ArpeggioType.major,
          ArpeggioOctaves.one,
        );
        final oneOctaveBoth = oneOctave.getHandSequence(4, HandSelection.both);
        expect(bothHandsSequence.length, greaterThan(oneOctaveBoth.length));
      });

      test("should handle 7th chord arpeggios for all hands", () {
        final arpeggioTypes = [
          ArpeggioType.dominant7,
          ArpeggioType.minor7,
          ArpeggioType.major7,
        ];

        for (final type in arpeggioTypes) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            type,
            ArpeggioOctaves.one,
          );

          // Test all hand selections
          for (final hand in HandSelection.values) {
            final sequence = arpeggio.getHandSequence(4, hand);
            expect(
              sequence,
              isNotEmpty,
              reason: "$type with $hand should not be empty",
            );

            // Both hands should have paired notes
            if (hand == HandSelection.both) {
              expect(sequence.length % 2, equals(0));
              for (var i = 0; i < sequence.length; i += 2) {
                final leftNote = sequence[i];
                final rightNote = sequence[i + 1];
                expect(leftNote, equals(rightNote - 12));
              }
            }
          }
        }
      });

      test("should handle all arpeggio types with hand selection", () {
        final types = [
          ArpeggioType.major,
          ArpeggioType.minor,
          ArpeggioType.diminished,
          ArpeggioType.augmented,
        ];

        for (final type in types) {
          final arpeggio = ArpeggioDefinitions.getArpeggio(
            MusicalNote.c,
            type,
            ArpeggioOctaves.one,
          );

          // Test both hands mode
          final bothHandsSequence = arpeggio.getHandSequence(
            4,
            HandSelection.both,
          );

          // Should have even length
          expect(
            bothHandsSequence.length % 2,
            equals(0),
            reason: "$type both hands should have paired notes",
          );

          // Verify interleaving pattern
          for (var i = 0; i < bothHandsSequence.length; i += 2) {
            final leftNote = bothHandsSequence[i];
            final rightNote = bothHandsSequence[i + 1];
            expect(
              leftNote,
              equals(rightNote - 12),
              reason: "$type should maintain 12-semitone offset",
            );
          }
        }
      });
    });
  });
}
