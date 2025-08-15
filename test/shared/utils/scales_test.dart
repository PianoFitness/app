import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

void main() {
  group("ScaleDefinitions", () {
    group("Scale generation", () {
      test("should create C Major scale correctly", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
        expect(scale.key, equals(Key.c));
        expect(scale.type, equals(ScaleType.major));
        expect(scale.name, equals("C Major (Ionian)"));
        expect(scale.intervals, equals([2, 2, 1, 2, 2, 2, 1]));
      });

      test("should create scales for all keys", () {
        for (final key in Key.values) {
          final scale = ScaleDefinitions.getScale(key, ScaleType.major);
          expect(scale.key, equals(key));
          expect(scale.type, equals(ScaleType.major));
          expect(scale.intervals, isNotEmpty);
        }
      });

      test("should create scales for all types", () {
        for (final type in ScaleType.values) {
          final scale = ScaleDefinitions.getScale(Key.c, type);
          expect(scale.key, equals(Key.c));
          expect(scale.type, equals(type));
          expect(scale.intervals, isNotEmpty);
        }
      });
    });

    group("Scale intervals", () {
      final expectedIntervals = {
        ScaleType.major: [2, 2, 1, 2, 2, 2, 1],
        ScaleType.minor: [2, 1, 2, 2, 1, 2, 2],
        ScaleType.dorian: [2, 1, 2, 2, 2, 1, 2],
        ScaleType.phrygian: [1, 2, 2, 2, 1, 2, 2],
        ScaleType.lydian: [2, 2, 2, 1, 2, 2, 1],
        ScaleType.mixolydian: [2, 2, 1, 2, 2, 1, 2],
        ScaleType.aeolian: [2, 1, 2, 2, 1, 2, 2],
        ScaleType.locrian: [1, 2, 2, 1, 2, 2, 2],
      };

      for (final entry in expectedIntervals.entries) {
        test("should have correct intervals for ${entry.key}", () {
          final scale = ScaleDefinitions.getScale(Key.c, entry.key);
          expect(scale.intervals, equals(entry.value));
        });
      }
    });

    group("C Major scale notes", () {
      test("should generate correct note sequence", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
        final notes = scale.getNotes();

        expect(notes.length, equals(8)); // 7 notes + octave
        expect(notes[0], equals(MusicalNote.c)); // C
        expect(notes[1], equals(MusicalNote.d)); // D
        expect(notes[2], equals(MusicalNote.e)); // E
        expect(notes[3], equals(MusicalNote.f)); // F
        expect(notes[4], equals(MusicalNote.g)); // G
        expect(notes[5], equals(MusicalNote.a)); // A
        expect(notes[6], equals(MusicalNote.b)); // B
        expect(notes[7], equals(MusicalNote.c)); // C (octave)
      });

      test("should generate correct MIDI sequence for C Major", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
        final midiNotes = scale.getMidiNotes(4);

        expect(midiNotes, equals([60, 62, 64, 65, 67, 69, 71, 72])); // C4-C5
      });

      test("should generate correct full scale sequence", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
        final fullSequence = scale.getFullScaleSequence(4);

        // Ascending: C4, D4, E4, F4, G4, A4, B4, C5
        // Descending: B4, A4, G4, F4, E4, D4, C4
        final expected = [
          60,
          62,
          64,
          65,
          67,
          69,
          71,
          72,
          71,
          69,
          67,
          65,
          64,
          62,
          60,
        ];
        expect(fullSequence, equals(expected));
      });
    });

    group("Church modes in different keys", () {
      final testCases = [
        {
          "key": Key.c,
          "type": ScaleType.major,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.b,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.dorian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.dSharp,
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.aSharp,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.phrygian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.cSharp,
            MusicalNote.dSharp,
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.gSharp,
            MusicalNote.aSharp,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.lydian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.fSharp,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.b,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.mixolydian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.aSharp,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.aeolian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.dSharp,
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.gSharp,
            MusicalNote.aSharp,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.c,
          "type": ScaleType.locrian,
          "expectedNotes": [
            MusicalNote.c,
            MusicalNote.cSharp,
            MusicalNote.dSharp,
            MusicalNote.f,
            MusicalNote.fSharp,
            MusicalNote.gSharp,
            MusicalNote.aSharp,
            MusicalNote.c,
          ],
        },
        {
          "key": Key.g,
          "type": ScaleType.major,
          "expectedNotes": [
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.b,
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.fSharp,
            MusicalNote.g,
          ],
        },
        {
          "key": Key.d,
          "type": ScaleType.major,
          "expectedNotes": [
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.fSharp,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.b,
            MusicalNote.cSharp,
            MusicalNote.d,
          ],
        },
        {
          "key": Key.f,
          "type": ScaleType.major,
          "expectedNotes": [
            MusicalNote.f,
            MusicalNote.g,
            MusicalNote.a,
            MusicalNote.aSharp,
            MusicalNote.c,
            MusicalNote.d,
            MusicalNote.e,
            MusicalNote.f,
          ],
        },
      ];

      for (final testCase in testCases) {
        test(
          'should generate correct notes for ${testCase['key']} ${testCase['type']}',
          () {
            final scale = ScaleDefinitions.getScale(
              testCase["key"]! as Key,
              testCase["type"]! as ScaleType,
            );
            final notes = scale.getNotes();
            final expected = testCase["expectedNotes"]! as List<MusicalNote>;

            expect(
              notes,
              equals(expected),
              reason:
                  'Scale ${testCase['key']} ${testCase['type']} should match expected notes',
            );
          },
        );
      }
    });

    group("Scale properties", () {
      test("all scales should have 8 notes (including octave)", () {
        for (final key in Key.values) {
          for (final type in ScaleType.values) {
            final scale = ScaleDefinitions.getScale(key, type);
            final notes = scale.getNotes();
            expect(
              notes.length,
              equals(8),
              reason: "Scale $key $type should have 8 notes",
            );
          }
        }
      });

      test("all scales should start and end with the same note", () {
        for (final key in Key.values) {
          for (final type in ScaleType.values) {
            final scale = ScaleDefinitions.getScale(key, type);
            final notes = scale.getNotes();
            expect(
              notes.first,
              equals(notes.last),
              reason: "Scale $key $type should start and end with same note",
            );
          }
        }
      });

      test("all scales should have 7 unique intervals", () {
        for (final type in ScaleType.values) {
          final scale = ScaleDefinitions.getScale(Key.c, type);
          expect(
            scale.intervals.length,
            equals(7),
            reason: "Scale $type should have 7 intervals",
          );

          final sum = scale.intervals.reduce((a, b) => a + b);
          expect(
            sum,
            equals(12),
            reason: "Scale $type intervals should sum to 12 semitones",
          );
        }
      });
    });

    group("MIDI note generation", () {
      test("should generate ascending MIDI notes correctly", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
        final midiNotes = scale.getMidiNotes(4);

        // Should be ascending
        for (var i = 1; i < midiNotes.length; i++) {
          expect(
            midiNotes[i],
            greaterThan(midiNotes[i - 1]),
            reason: "MIDI notes should be ascending",
          );
        }
      });

      test("should handle octave wrapping correctly", () {
        // Test with scales that cross octave boundaries
        final scale = ScaleDefinitions.getScale(Key.fSharp, ScaleType.major);
        final midiNotes = scale.getMidiNotes(4);

        expect(midiNotes.length, equals(8));
        expect(midiNotes.first, equals(66)); // F#4
        expect(midiNotes.last, equals(78)); // F#5
      });

      test("should generate different octaves correctly", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);

        final octave3 = scale.getMidiNotes(3);
        final octave4 = scale.getMidiNotes(4);
        final octave5 = scale.getMidiNotes(5);

        for (var i = 0; i < octave3.length; i++) {
          expect(octave4[i] - octave3[i], equals(12));
          expect(octave5[i] - octave4[i], equals(12));
        }
      });
    });

    group("cMajor convenience method", () {
      test("should return C Major scale", () {
        final scale = ScaleDefinitions.cMajor;
        expect(scale.key, equals(Key.c));
        expect(scale.type, equals(ScaleType.major));
        expect(scale.name, equals("C Major (Ionian)"));
      });
    });

    group("Additional comprehensive coverage", () {
      test("should handle all scale-key combinations correctly", () {
        var totalCombinations = 0;

        for (final key in Key.values) {
          for (final scaleType in ScaleType.values) {
            final scale = ScaleDefinitions.getScale(key, scaleType);

            // Basic validations
            expect(scale.key, equals(key));
            expect(scale.type, equals(scaleType));
            expect(scale.name, isNotEmpty);
            expect(scale.intervals, hasLength(7));

            // Intervals should sum to 12 semitones (full octave)
            final intervalSum = scale.intervals.reduce((a, b) => a + b);
            expect(intervalSum, equals(12));

            // Should generate 8 notes (including octave)
            final notes = scale.getNotes();
            expect(notes, hasLength(8));
            expect(
              notes.first,
              equals(notes.last),
            ); // First and last should be same note

            // MIDI generation
            final midiNotes = scale.getMidiNotes(4);
            expect(midiNotes, hasLength(8));

            // Should be ascending
            for (var i = 1; i < midiNotes.length; i++) {
              expect(midiNotes[i], greaterThan(midiNotes[i - 1]));
            }

            // Full scale sequence (up and down)
            final fullSequence = scale.getFullScaleSequence(4);
            expect(fullSequence, hasLength(15)); // 8 up + 7 down
            expect(fullSequence.first, equals(fullSequence.last));

            totalCombinations++;
          }
        }

        // Ensure we tested all expected combinations
        expect(
          totalCombinations,
          equals(12 * 8),
        ); // 12 keys × 8 scale types = 96
      });

      test("should generate correct MIDI notes across all octaves", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);

        for (var octave = 0; octave <= 8; octave++) {
          final midiNotes = scale.getMidiNotes(octave);
          expect(midiNotes, hasLength(8));

          // Should be ascending
          for (var i = 1; i < midiNotes.length; i++) {
            expect(midiNotes[i], greaterThan(midiNotes[i - 1]));
          }

          // First note should be the correct octave
          final expectedFirstMidi = NoteUtils.noteToMidiNumber(
            MusicalNote.c,
            octave,
          );
          expect(midiNotes.first, equals(expectedFirstMidi));

          // Last note should be one octave higher
          expect(midiNotes.last, equals(expectedFirstMidi + 12));

          // Full sequence validation
          final fullSequence = scale.getFullScaleSequence(octave);
          expect(fullSequence.first, equals(expectedFirstMidi));
          expect(fullSequence.last, equals(expectedFirstMidi));
        }
      });

      test("should handle enharmonic equivalents correctly", () {
        // Test scales that involve complex note relationships
        final testCases = [
          {"key": Key.fSharp, "type": ScaleType.major},
          {"key": Key.cSharp, "type": ScaleType.major},
          {"key": Key.gSharp, "type": ScaleType.minor},
          {"key": Key.aSharp, "type": ScaleType.minor},
        ];

        for (final testCase in testCases) {
          final scale = ScaleDefinitions.getScale(
            testCase["key"]! as Key,
            testCase["type"]! as ScaleType,
          );

          expect(scale.intervals, hasLength(7));
          expect(scale.intervals.reduce((a, b) => a + b), equals(12));

          final notes = scale.getNotes();
          expect(notes, hasLength(8));
          expect(notes.first, equals(notes.last));

          final midiNotes = scale.getMidiNotes(4);
          expect(midiNotes, hasLength(8));

          // Should maintain ascending order
          for (var i = 1; i < midiNotes.length; i++) {
            expect(midiNotes[i], greaterThan(midiNotes[i - 1]));
          }
        }
      });

      test("should validate all mode relationships", () {
        // Each mode should have the correct interval pattern
        final modeIntervals = {
          ScaleType.major: [2, 2, 1, 2, 2, 2, 1], // Ionian
          ScaleType.dorian: [2, 1, 2, 2, 2, 1, 2], // Dorian
          ScaleType.phrygian: [1, 2, 2, 2, 1, 2, 2], // Phrygian
          ScaleType.lydian: [2, 2, 2, 1, 2, 2, 1], // Lydian
          ScaleType.mixolydian: [2, 2, 1, 2, 2, 1, 2], // Mixolydian
          ScaleType.minor: [2, 1, 2, 2, 1, 2, 2], // Natural Minor (Aeolian)
          ScaleType.aeolian: [
            2,
            1,
            2,
            2,
            1,
            2,
            2,
          ], // Aeolian (same as natural minor)
          ScaleType.locrian: [1, 2, 2, 1, 2, 2, 2], // Locrian
        };

        for (final entry in modeIntervals.entries) {
          final scale = ScaleDefinitions.getScale(Key.c, entry.key);
          expect(
            scale.intervals,
            equals(entry.value),
            reason: "Scale ${entry.key} should have intervals ${entry.value}",
          );
        }
      });

      test("should generate consistent results across multiple calls", () {
        // Ensure that multiple calls return identical results (no random behavior)
        for (final key in Key.values) {
          for (final scaleType in ScaleType.values) {
            final scale1 = ScaleDefinitions.getScale(key, scaleType);
            final scale2 = ScaleDefinitions.getScale(key, scaleType);

            expect(scale1.key, equals(scale2.key));
            expect(scale1.type, equals(scale2.type));
            expect(scale1.name, equals(scale2.name));
            expect(scale1.intervals, equals(scale2.intervals));
            expect(scale1.getNotes(), equals(scale2.getNotes()));
            expect(scale1.getMidiNotes(4), equals(scale2.getMidiNotes(4)));
            expect(
              scale1.getFullScaleSequence(4),
              equals(scale2.getFullScaleSequence(4)),
            );
          }
        }
      });

      test("should handle extreme octave ranges", () {
        final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);

        // Test very low octave
        final lowMidi = scale.getMidiNotes(0);
        expect(lowMidi, hasLength(8));
        expect(lowMidi.first, equals(12)); // C0
        expect(lowMidi.last, equals(24)); // C1

        // Test very high octave (careful not to exceed MIDI range)
        final highMidi = scale.getMidiNotes(8);
        expect(highMidi, hasLength(8));
        expect(highMidi.first, equals(108)); // C8
        for (final midi in highMidi) {
          expect(midi, lessThanOrEqualTo(127)); // Don't exceed MIDI range
        }
      });
    });
  });

  group("KeyDisplay Extension", () {
    group("displayName", () {
      test("should return correct names for natural keys", () {
        expect(Key.c.displayName, equals("C"));
        expect(Key.d.displayName, equals("D"));
        expect(Key.e.displayName, equals("E"));
        expect(Key.f.displayName, equals("F"));
        expect(Key.g.displayName, equals("G"));
        expect(Key.a.displayName, equals("A"));
        expect(Key.b.displayName, equals("B"));
      });

      test("should return flat notation for enharmonic keys", () {
        expect(Key.cSharp.displayName, equals("D♭"));
        expect(Key.dSharp.displayName, equals("E♭"));
        expect(Key.fSharp.displayName, equals("G♭"));
        expect(Key.gSharp.displayName, equals("A♭"));
        expect(Key.aSharp.displayName, equals("B♭"));
      });

      test("should use conventional flat notation over sharp notation", () {
        // These tests verify that the extension follows musical conventions
        // where flat notation is preferred for key signatures
        expect(Key.cSharp.displayName, isNot(equals("C#")));
        expect(Key.dSharp.displayName, isNot(equals("D#")));
        expect(Key.fSharp.displayName, isNot(equals("F#")));
        expect(Key.gSharp.displayName, isNot(equals("G#")));
        expect(Key.aSharp.displayName, isNot(equals("A#")));
      });

      test("should return consistent results for all keys", () {
        for (final key in Key.values) {
          final displayName = key.displayName;
          expect(displayName, isNotEmpty);
          expect(displayName, isA<String>());

          // Verify the name contains expected musical notation
          final isNaturalKey = [
            "C",
            "D",
            "E",
            "F",
            "G",
            "A",
            "B",
          ].contains(displayName);
          final isFlatKey = displayName.contains("♭");

          expect(
            isNaturalKey || isFlatKey,
            isTrue,
            reason: "Key $key should have either natural or flat notation",
          );
        }
      });
    });

    group("fullDisplayName", () {
      test("should return just the key name for natural keys", () {
        expect(Key.c.fullDisplayName, equals("C"));
        expect(Key.d.fullDisplayName, equals("D"));
        expect(Key.e.fullDisplayName, equals("E"));
        expect(Key.f.fullDisplayName, equals("F"));
        expect(Key.g.fullDisplayName, equals("G"));
        expect(Key.a.fullDisplayName, equals("A"));
        expect(Key.b.fullDisplayName, equals("B"));
      });

      test("should include enharmonic equivalent for black keys", () {
        expect(Key.cSharp.fullDisplayName, equals("D♭ (C#)"));
        expect(Key.dSharp.fullDisplayName, equals("E♭ (D#)"));
        expect(Key.fSharp.fullDisplayName, equals("G♭ (F#)"));
        expect(Key.gSharp.fullDisplayName, equals("A♭ (G#)"));
        expect(Key.aSharp.fullDisplayName, equals("B♭ (A#)"));
      });

      test("should show flat notation first, sharp in parentheses", () {
        for (final key in Key.values) {
          final fullName = key.fullDisplayName;

          if (fullName.contains("(")) {
            // For enharmonic keys, verify format: "Flat (Sharp)"
            expect(fullName, matches(r"^[A-G]♭ \([A-G]#\)$"));
            expect(fullName.indexOf("♭"), lessThan(fullName.indexOf("#")));
          } else {
            // For natural keys, verify single letter format
            expect(fullName, matches(r"^[A-G]$"));
          }
        }
      });

      test("should be consistent for all keys", () {
        for (final key in Key.values) {
          final fullDisplayName = key.fullDisplayName;
          expect(fullDisplayName, isNotEmpty);
          expect(fullDisplayName, isA<String>());

          // Multiple calls should return same result
          expect(key.fullDisplayName, equals(fullDisplayName));
        }
      });
    });

    group("KeyDisplay integration", () {
      test("should integrate properly with scale name generation", () {
        // Test that the extension works correctly when used in ScaleDefinitions
        for (final key in Key.values) {
          final scale = ScaleDefinitions.getScale(key, ScaleType.major);
          final expectedKeyName = key.displayName;

          expect(scale.name, contains(expectedKeyName));
          expect(scale.name, endsWith(" Major (Ionian)"));
        }
      });

      test("should provide readable names for user interfaces", () {
        // Test that names are appropriate for display in UI
        for (final key in Key.values) {
          final displayName = key.displayName;
          final fullDisplayName = key.fullDisplayName;

          // Keep names concise for UI, but avoid brittle hard caps.
          expect(displayName, matches(r"^[A-G]$|^[A-G]♭$"));
          // Full name either a single letter or "X♭ (Y#)"
          if (fullDisplayName.contains("(")) {
            expect(fullDisplayName, matches(r"^[A-G]♭ \([A-G]#\)$"));
          } else {
            expect(fullDisplayName, matches(r"^[A-G]$"));
          }

          // Should not contain special characters except musical symbols
          expect(displayName, matches(r"^[A-G♭]+$"));
        }
      });

      test("should maintain musical conventions across all keys", () {
        final expectedNaturalKeys = ["C", "D", "E", "F", "G", "A", "B"];
        final expectedFlatKeys = ["D♭", "E♭", "G♭", "A♭", "B♭"];

        final actualDisplayNames = Key.values
            .map((k) => k.displayName)
            .toList();

        // Verify we have exactly the expected natural keys
        for (final natural in expectedNaturalKeys) {
          expect(actualDisplayNames, contains(natural));
        }

        // Verify we have exactly the expected flat keys
        for (final flat in expectedFlatKeys) {
          expect(actualDisplayNames, contains(flat));
        }

        // Verify total count matches enum values
        expect(actualDisplayNames.length, equals(Key.values.length));
      });
    });

    group("Edge cases and validation", () {
      test("should handle all Key enum values", () {
        // Ensure no Key values are missing from the extension
        for (final key in Key.values) {
          expect(() => key.displayName, returnsNormally);
          expect(() => key.fullDisplayName, returnsNormally);
        }
      });

      test("should return non-null, non-empty strings", () {
        for (final key in Key.values) {
          final displayName = key.displayName;
          final fullDisplayName = key.fullDisplayName;

          expect(displayName, isNotNull);
          expect(displayName, isNotEmpty);
          expect(fullDisplayName, isNotNull);
          expect(fullDisplayName, isNotEmpty);
        }
      });

      test("should be deterministic across multiple calls", () {
        for (final key in Key.values) {
          final name1 = key.displayName;
          final name2 = key.displayName;
          final fullName1 = key.fullDisplayName;
          final fullName2 = key.fullDisplayName;

          expect(name1, equals(name2));
          expect(fullName1, equals(fullName2));
        }
      });
    });
  });
}
