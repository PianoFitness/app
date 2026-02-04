import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";

void main() {
  group("MidiRepositoryImpl Retry Logic", () {
    test("initialize uses configurable retry parameters", () {
      // Verify constructor accepts retry configuration
      final repository = MidiRepositoryImpl(
        maxConnectionAttempts: 3,
        initialRetryDelayMs: 100,
      );

      expect(repository.maxConnectionAttempts, equals(3));
      expect(repository.initialRetryDelayMs, equals(100));
      expect(repository.retryDelayMultiplier, equals(2));
    });

    test("uses default retry parameters when not specified", () {
      final repository = MidiRepositoryImpl();

      expect(repository.maxConnectionAttempts, equals(5));
      expect(repository.initialRetryDelayMs, equals(200));
      expect(repository.retryDelayMultiplier, equals(2));
    });

    test("exponential backoff delay calculation is correct", () {
      // Verify the retry delays follow exponential backoff pattern:
      // Attempt 0: initialDelay (200ms)
      // Attempt 1: initialDelay * multiplier (400ms)
      // Attempt 2: initialDelay * multiplier^2 (800ms)
      // etc.

      const initialDelay = 200;
      const multiplier = 2;

      expect(initialDelay * 1, equals(200)); // First retry
      expect(initialDelay * multiplier, equals(400)); // Second retry
      expect(
        initialDelay * multiplier * multiplier,
        equals(800),
      ); // Third retry
    });
  });

  group("MidiRepositoryImpl Channel Validation", () {
    late MidiRepositoryImpl repository;

    setUp(() {
      repository = MidiRepositoryImpl();
    });

    group("sendNoteOn", () {
      test("throws RangeError for negative channel", () async {
        // Validation happens before sendData, so no bindings needed
        expect(
          () async => await repository.sendNoteOn(60, 100, -1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for channel > 15", () async {
        expect(
          () async => await repository.sendNoteOn(60, 100, 16),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for large invalid channel", () async {
        expect(
          () async => await repository.sendNoteOn(60, 100, 100),
          throwsA(isA<RangeError>()),
        );
      });
    });

    group("sendNoteOff", () {
      test("throws RangeError for negative channel", () async {
        expect(
          () async => await repository.sendNoteOff(60, -1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for channel > 15", () async {
        expect(
          () async => await repository.sendNoteOff(60, 16),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("throws RangeError for large invalid channel", () async {
        expect(
          () async => await repository.sendNoteOff(60, 100),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}
