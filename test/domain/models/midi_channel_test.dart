import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/midi_channel.dart";

void main() {
  group("MidiChannel", () {
    group("Constructor", () {
      test("accepts valid channel (0)", () {
        expect(() => MidiChannel(0), returnsNormally);
      });

      test("accepts valid channel (15)", () {
        expect(() => MidiChannel(15), returnsNormally);
      });

      test("accepts valid channel (7)", () {
        expect(() => MidiChannel(7), returnsNormally);
      });

      test("throws RangeError for negative channel", () {
        expect(
          () => MidiChannel(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for channel > 15", () {
        expect(
          () => MidiChannel(16),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for large negative channel", () {
        expect(() => MidiChannel(-100), throwsA(isA<RangeError>()));
      });

      test("throws RangeError for large positive channel", () {
        expect(() => MidiChannel(100), throwsA(isA<RangeError>()));
      });
    });

    group("validate", () {
      test("does not throw for valid channel (0)", () {
        expect(() => MidiChannel.validate(0), returnsNormally);
      });

      test("does not throw for valid channel (15)", () {
        expect(() => MidiChannel.validate(15), returnsNormally);
      });

      test("does not throw for valid channel (7)", () {
        expect(() => MidiChannel.validate(7), returnsNormally);
      });

      test("throws RangeError for negative channel", () {
        expect(
          () => MidiChannel.validate(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for channel > 15", () {
        expect(
          () => MidiChannel.validate(16),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });
    });

    group("isValid", () {
      test("returns true for channel 0", () {
        expect(MidiChannel.isValid(0), isTrue);
      });

      test("returns true for channel 15", () {
        expect(MidiChannel.isValid(15), isTrue);
      });

      test("returns true for channel 7", () {
        expect(MidiChannel.isValid(7), isTrue);
      });

      test("returns false for negative channel", () {
        expect(MidiChannel.isValid(-1), isFalse);
      });

      test("returns false for channel > 15", () {
        expect(MidiChannel.isValid(16), isFalse);
      });

      test("returns false for large negative channel", () {
        expect(MidiChannel.isValid(-100), isFalse);
      });

      test("returns false for large positive channel", () {
        expect(MidiChannel.isValid(100), isFalse);
      });
    });

    group("Constants", () {
      test("min is 0", () {
        expect(MidiChannel.min, equals(0));
      });

      test("max is 15", () {
        expect(MidiChannel.max, equals(15));
      });
    });

    group("Equality", () {
      test("equal channels are equal", () {
        final channel1 = MidiChannel(5);
        final channel2 = MidiChannel(5);
        expect(channel1, equals(channel2));
      });

      test("different channels are not equal", () {
        final channel1 = MidiChannel(5);
        final channel2 = MidiChannel(10);
        expect(channel1, isNot(equals(channel2)));
      });

      test("equal channels have same hashCode", () {
        final channel1 = MidiChannel(5);
        final channel2 = MidiChannel(5);
        expect(channel1.hashCode, equals(channel2.hashCode));
      });
    });

    group("toString", () {
      test("returns readable string representation", () {
        final channel = MidiChannel(7);
        expect(channel.toString(), equals("MidiChannel(7)"));
      });

      test("works for boundary values", () {
        expect(MidiChannel(0).toString(), equals("MidiChannel(0)"));
        expect(MidiChannel(15).toString(), equals("MidiChannel(15)"));
      });
    });

    group("value getter", () {
      test("returns the channel value", () {
        final channel = MidiChannel(7);
        expect(channel.value, equals(7));
      });

      test("returns correct value for boundary cases", () {
        expect(MidiChannel(0).value, equals(0));
        expect(MidiChannel(15).value, equals(15));
      });
    });
  });
}
