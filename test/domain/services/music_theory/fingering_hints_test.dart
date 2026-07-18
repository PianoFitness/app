import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/fingering_hints.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart";

const _blackPitchClasses = {1, 3, 6, 8, 10};

void main() {
  group("FingeringHints.scale", () {
    for (final key in Key.values) {
      for (final scaleType in ScaleType.values) {
        test("${key.name} ${scaleType.name} has one finger per note, values 1-5", () {
          final scale = ScaleDefinitions.getScale(key, scaleType);
          final notes = scale.getNotes();
          final expectedLength = scale.getFullScaleSequence(4).length;

          for (final rightHand in [true, false]) {
            final fingers = FingeringHints.scale(
              key: key,
              scaleType: scaleType,
              notes: notes,
              rightHand: rightHand,
            );
            expect(fingers.length, expectedLength);
            expect(fingers.every((f) => f >= 1 && f <= 5), isTrue);
          }
        });
      }
    }

    test("right-hand thumb never lands on a black key for major scales", () {
      for (final key in Key.values) {
        final scale = ScaleDefinitions.getScale(key, ScaleType.major);
        final notes = scale.getNotes();
        final fingers = FingeringHints.scale(
          key: key,
          scaleType: ScaleType.major,
          notes: notes,
          rightHand: true,
        );
        for (var i = 0; i < notes.length; i++) {
          if (fingers[i] == 1) {
            expect(
              _blackPitchClasses.contains(notes[i].index),
              isFalse,
              reason: "${key.name} major: thumb landed on black key at degree ${i + 1}",
            );
          }
        }
      }
    });

    test("right-hand thumb never lands on a black key for natural minor scales", () {
      for (final key in Key.values) {
        final scale = ScaleDefinitions.getScale(key, ScaleType.minor);
        final notes = scale.getNotes();
        final fingers = FingeringHints.scale(
          key: key,
          scaleType: ScaleType.minor,
          notes: notes,
          rightHand: true,
        );
        for (var i = 0; i < notes.length; i++) {
          if (fingers[i] == 1) {
            expect(
              _blackPitchClasses.contains(notes[i].index),
              isFalse,
              reason: "${key.name} minor: thumb landed on black key at degree ${i + 1}",
            );
          }
        }
      }
    });

    test("aeolian matches natural minor (identical intervals)", () {
      final scale = ScaleDefinitions.getScale(Key.g, ScaleType.aeolian);
      final notes = scale.getNotes();
      final aeolianFingers = FingeringHints.scale(
        key: Key.g,
        scaleType: ScaleType.aeolian,
        notes: notes,
        rightHand: true,
      );
      final minorFingers = FingeringHints.scale(
        key: Key.g,
        scaleType: ScaleType.minor,
        notes: notes,
        rightHand: true,
      );
      expect(aeolianFingers, minorFingers);
    });

    test("C major matches the textbook fingering", () {
      final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
      final notes = scale.getNotes();
      expect(
        FingeringHints.scale(key: Key.c, scaleType: ScaleType.major, notes: notes, rightHand: true),
        [1, 2, 3, 1, 2, 3, 4, 5, 4, 3, 2, 1, 3, 2, 1],
      );
      expect(
        FingeringHints.scale(key: Key.c, scaleType: ScaleType.major, notes: notes, rightHand: false),
        [5, 4, 3, 2, 1, 3, 2, 1, 2, 3, 1, 2, 3, 4, 5],
      );
    });
  });

  group("FingeringHints.arpeggio", () {
    for (final rootNote in MusicalNote.values) {
      for (final arpeggioType in ArpeggioType.values) {
        for (final octaves in ArpeggioOctaves.values) {
          test(
            "${rootNote.name} ${arpeggioType.name} (${octaves.name}) has one finger per note, values 1-5",
            () {
              final arpeggio = ArpeggioDefinitions.getArpeggio(rootNote, arpeggioType, octaves);
              final expectedLength = arpeggio.getFullArpeggioSequence(4).length;

              for (final rightHand in [true, false]) {
                final fingers = FingeringHints.arpeggio(
                  rootNote: rootNote,
                  arpeggioType: arpeggioType,
                  octaves: octaves,
                  rightHand: rightHand,
                );
                expect(fingers.length, expectedLength);
                expect(fingers.every((f) => f >= 1 && f <= 5), isTrue);
              }
            },
          );
        }
      }
    }

    test("C major triad, one octave, matches the textbook fingering", () {
      expect(
        FingeringHints.arpeggio(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          octaves: ArpeggioOctaves.one,
          rightHand: true,
        ),
        [1, 2, 3, 5, 3, 2, 1],
      );
      expect(
        FingeringHints.arpeggio(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          octaves: ArpeggioOctaves.one,
          rightHand: false,
        ),
        [5, 3, 2, 1, 2, 3, 5],
      );
    });
  });
}
