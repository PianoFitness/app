import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";

import "../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MidiRepositoryImpl Retry Logic", () {
    late MockMidiConnectionService mockService;
    late MockMidiCommand mockMidiCommand;

    setUp(() {
      mockService = MockMidiConnectionService();
      mockMidiCommand = MockMidiCommand();

      // Stub connect() to return successfully
      when(mockService.connect()).thenAnswer((_) async => Future<void>.value());
    });

    test("initialize uses configurable retry parameters", () {
      // Verify constructor accepts retry configuration
      final repository = MidiRepositoryImpl(
        maxConnectionAttempts: 3,
        initialRetryDelayMs: 100,
        service: mockService,
        midiCommand: mockMidiCommand,
      );

      expect(repository.maxConnectionAttempts, equals(3));
      expect(repository.initialRetryDelayMs, equals(100));
      expect(repository.retryDelayMultiplier, equals(2));
    });

    test("uses default retry parameters when not specified", () {
      final repository = MidiRepositoryImpl(
        service: mockService,
        midiCommand: mockMidiCommand,
      );

      expect(repository.maxConnectionAttempts, equals(5));
      expect(repository.initialRetryDelayMs, equals(200));
      expect(repository.retryDelayMultiplier, equals(2));
    });

    test(
      "retry delay configuration produces correct exponential backoff sequence",
      () {
        // This test verifies the repository's retry configuration parameters
        // will produce the expected exponential backoff delays when used in
        // the formula: delay = initialRetryDelayMs * (retryDelayMultiplier ^ attempt)

        final repository = MidiRepositoryImpl(
          maxConnectionAttempts: 4,
          initialRetryDelayMs: 100,
          service: mockService,
          midiCommand: mockMidiCommand,
        );

        // Simulate the delay calculation that occurs in _connectWithRetry
        var currentDelay = repository.initialRetryDelayMs;
        final delays = <int>[];

        for (
          var attempt = 0;
          attempt < repository.maxConnectionAttempts;
          attempt++
        ) {
          delays.add(currentDelay);
          currentDelay *= repository.retryDelayMultiplier;
        }

        // Verify the sequence matches expected exponential backoff
        expect(delays, equals([100, 200, 400, 800]));
      },
    );

    test("default retry configuration produces correct delay sequence", () {
      // Verify default retry configuration follows exponential backoff
      final repository = MidiRepositoryImpl(
        service: mockService,
        midiCommand: mockMidiCommand,
      );

      // Simulate the delay calculation using repository's configuration
      var currentDelay = repository.initialRetryDelayMs;
      final delays = <int>[];

      for (
        var attempt = 0;
        attempt < repository.maxConnectionAttempts;
        attempt++
      ) {
        delays.add(currentDelay);
        currentDelay *= repository.retryDelayMultiplier;
      }

      // With defaults: initialRetryDelayMs=200, multiplier=2, maxAttempts=5
      expect(delays, equals([200, 400, 800, 1600, 3200]));
    });
  });

  group("MidiRepositoryImpl Channel Validation", () {
    late MidiRepositoryImpl repository;
    late MockMidiConnectionService mockService;
    late MockMidiCommand mockMidiCommand;

    setUp(() {
      mockService = MockMidiConnectionService();
      mockMidiCommand = MockMidiCommand();

      // Stub required methods
      when(mockService.connect()).thenAnswer((_) async => Future<void>.value());

      repository = MidiRepositoryImpl(
        service: mockService,
        midiCommand: mockMidiCommand,
      );
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
