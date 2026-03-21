import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/midi_note.dart";

void main() {
  group("MidiNote", () {
    group("Constructor", () {
      test("accepts valid note (0)", () {
        expect(() => MidiNote(0), returnsNormally);
      });

      test("accepts valid note (127)", () {
        expect(() => MidiNote(127), returnsNormally);
      });

      test("accepts valid note (60 — middle C)", () {
        expect(() => MidiNote(60), returnsNormally);
      });

      test("throws RangeError for negative note", () {
        expect(
          () => MidiNote(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI note must be between 0 and 127"),
            ),
          ),
        );
      });

      test("throws RangeError for note > 127", () {
        expect(
          () => MidiNote(128),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI note must be between 0 and 127"),
            ),
          ),
        );
      });

      test("throws RangeError for large negative note", () {
        expect(() => MidiNote(-100), throwsA(isA<RangeError>()));
      });

      test("throws RangeError for large positive note", () {
        expect(() => MidiNote(200), throwsA(isA<RangeError>()));
      });
    });

    group("validate", () {
      test("does not throw for valid note (0)", () {
        expect(() => MidiNote.validate(0), returnsNormally);
      });

      test("does not throw for valid note (127)", () {
        expect(() => MidiNote.validate(127), returnsNormally);
      });

      test("does not throw for valid note (60)", () {
        expect(() => MidiNote.validate(60), returnsNormally);
      });

      test("throws RangeError for negative note", () {
        expect(
          () => MidiNote.validate(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI note must be between 0 and 127"),
            ),
          ),
        );
      });

      test("throws RangeError for note > 127", () {
        expect(
          () => MidiNote.validate(128),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI note must be between 0 and 127"),
            ),
          ),
        );
      });

      test("returns the note value when valid", () {
        expect(MidiNote.validate(60), equals(60));
        expect(MidiNote.validate(0), equals(0));
        expect(MidiNote.validate(127), equals(127));
      });
    });

    group("isValid", () {
      test("returns true for note 0", () {
        expect(MidiNote.isValid(0), isTrue);
      });

      test("returns true for note 127", () {
        expect(MidiNote.isValid(127), isTrue);
      });

      test("returns true for note 60", () {
        expect(MidiNote.isValid(60), isTrue);
      });

      test("returns false for negative note", () {
        expect(MidiNote.isValid(-1), isFalse);
      });

      test("returns false for note > 127", () {
        expect(MidiNote.isValid(128), isFalse);
      });

      test("returns false for large negative note", () {
        expect(MidiNote.isValid(-100), isFalse);
      });

      test("returns false for large positive note", () {
        expect(MidiNote.isValid(200), isFalse);
      });
    });

    group("Constants", () {
      test("min is 0", () {
        expect(MidiNote.min, equals(0));
      });

      test("max is 127", () {
        expect(MidiNote.max, equals(127));
      });
    });

    group("Equality", () {
      test("equal notes are equal", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(60);
        expect(note1, equals(note2));
      });

      test("different notes are not equal", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(62);
        expect(note1, isNot(equals(note2)));
      });

      test("equal notes have same hashCode", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(60);
        expect(note1.hashCode, equals(note2.hashCode));
      });
    });

    group("toString", () {
      test("returns readable string representation", () {
        final note = MidiNote(60);
        expect(note.toString(), equals("MidiNote(60)"));
      });

      test("works for boundary values", () {
        expect(MidiNote(0).toString(), equals("MidiNote(0)"));
        expect(MidiNote(127).toString(), equals("MidiNote(127)"));
      });
    });

    group("value getter", () {
      test("returns the note value", () {
        final note = MidiNote(60);
        expect(note.value, equals(60));
      });

      test("returns correct value for boundary cases", () {
        expect(MidiNote(0).value, equals(0));
        expect(MidiNote(127).value, equals(127));
      });
    });
  });
}
