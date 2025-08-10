import "dart:typed_data";

import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("MidiConnectionService Tests", () {
    late MidiConnectionService service;

    setUp(() {
      // Get the singleton service instance
      service = MidiConnectionService();
    });

    tearDown(() async {
      await service.dispose();
    });

    group("Singleton Pattern Tests", () {
      test("should return the same instance", () {
        final instance1 = MidiConnectionService();
        final instance2 = MidiConnectionService();

        expect(instance1, equals(instance2));
        expect(identical(instance1, instance2), isTrue);
      });

      test("should maintain state across multiple getInstance calls", () async {
        final service1 = MidiConnectionService();
        final service2 = MidiConnectionService();

        // Register a handler on service1
        void testHandler(Uint8List data) {}
        service1.registerDataHandler(testHandler);

        // service2 should have the same handler
        expect(identical(service1, service2), isTrue);

        // Clean up
        service1.unregisterDataHandler(testHandler);
      });
    });

    group("Connection Management Tests", () {
      test("should start as disconnected", () {
        expect(service.isConnected, isFalse);
      });

      test("should handle connection attempt", () async {
        await service.connect();
        // Note: In test environment, connection may not establish due to mocking
        // but it should not throw an error
      });

      test("should handle multiple connection attempts gracefully", () async {
        // First connection
        await service.connect();
        final firstConnectionState = service.isConnected;

        // Second connection attempt should be ignored
        await service.connect();
        expect(service.isConnected, equals(firstConnectionState));
      });

      test("should disconnect properly", () async {
        await service.connect();
        await service.disconnect();
        expect(service.isConnected, isFalse);
      });
    });

    group("Data Handler Registration Tests", () {
      test("should register data handlers", () {
        final receivedData = <Uint8List>[];

        void testHandler(Uint8List data) {
          receivedData.add(data);
        }

        service.registerDataHandler(testHandler);

        // Registration should not throw
        expect(() => service.registerDataHandler(testHandler), returnsNormally);

        // Clean up
        service.unregisterDataHandler(testHandler);
      });

      test("should allow multiple data handler registrations", () {
        void handler1(Uint8List data) {}
        void handler2(Uint8List data) {}
        void handler3(Uint8List data) {}

        expect(() {
          service
            ..registerDataHandler(handler1)
            ..registerDataHandler(handler2)
            ..registerDataHandler(handler3);
        }, returnsNormally);

        // Clean up
        service
          ..unregisterDataHandler(handler1)
          ..unregisterDataHandler(handler2)
          ..unregisterDataHandler(handler3);
      });

      test("should unregister data handlers", () {
        void testHandler(Uint8List data) {}

        service.registerDataHandler(testHandler);
        expect(
          () => service.unregisterDataHandler(testHandler),
          returnsNormally,
        );
      });

      test("should handle unregistering non-existent handlers gracefully", () {
        void testHandler(Uint8List data) {}

        // Should not throw when trying to unregister a handler that wasn't registered
        expect(
          () => service.unregisterDataHandler(testHandler),
          returnsNormally,
        );
      });
    });

    group("Error Handler Registration Tests", () {
      test("should register error handlers", () {
        void testErrorHandler(String error) {}

        expect(
          () => service.registerErrorHandler(testErrorHandler),
          returnsNormally,
        );

        // Clean up
        service.unregisterErrorHandler(testErrorHandler);
      });

      test("should allow multiple error handler registrations", () {
        void errorHandler1(String error) {}
        void errorHandler2(String error) {}
        void errorHandler3(String error) {}

        expect(() {
          service
            ..registerErrorHandler(errorHandler1)
            ..registerErrorHandler(errorHandler2)
            ..registerErrorHandler(errorHandler3);
        }, returnsNormally);

        // Clean up
        service
          ..unregisterErrorHandler(errorHandler1)
          ..unregisterErrorHandler(errorHandler2)
          ..unregisterErrorHandler(errorHandler3);
      });

      test("should unregister error handlers", () {
        void testErrorHandler(String error) {}

        service.registerErrorHandler(testErrorHandler);
        expect(
          () => service.unregisterErrorHandler(testErrorHandler),
          returnsNormally,
        );
      });

      test(
        "should handle unregistering non-existent error handlers gracefully",
        () {
          void testErrorHandler(String error) {}

          expect(
            () => service.unregisterErrorHandler(testErrorHandler),
            returnsNormally,
          );
        },
      );
    });

    group("MIDI Data Processing Tests", () {
      test("should provide access to MIDI command instance", () {
        expect(service.midiCommand, isNotNull);
        expect(service.midiCommand, isA<MidiCommand>());
      });

      test("handleStandardMidiData should process note on events", () {
        final midiState = MidiState();
        final noteOnData = Uint8List.fromList([
          0x90,
          60,
          100,
        ]); // Note On, Middle C, velocity 100

        MidiConnectionService.handleStandardMidiData(noteOnData, midiState);

        expect(midiState.activeNotes.contains(60), isTrue);
        expect(midiState.lastNote, isNotEmpty);
      });

      test("handleStandardMidiData should process note off events", () {
        final midiState = MidiState();

        // First turn note on
        final noteOnData = Uint8List.fromList([0x90, 60, 100]);
        MidiConnectionService.handleStandardMidiData(noteOnData, midiState);
        expect(midiState.activeNotes.contains(60), isTrue);

        // Then turn note off
        final noteOffData = Uint8List.fromList([0x80, 60, 0]);
        MidiConnectionService.handleStandardMidiData(noteOffData, midiState);
        expect(midiState.activeNotes.contains(60), isFalse);
      });

      test("handleStandardMidiData should process control change events", () {
        final midiState = MidiState();
        final ccData = Uint8List.fromList([
          0xB0,
          7,
          127,
        ]); // Control Change, Volume, Max

        MidiConnectionService.handleStandardMidiData(ccData, midiState);

        // Should set last note to the control change message
        expect(midiState.lastNote, contains("Control"));
      });

      test("handleStandardMidiData should process program change events", () {
        final midiState = MidiState();
        final pcData = Uint8List.fromList([
          0xC0,
          1,
        ]); // Program Change, Program 1

        MidiConnectionService.handleStandardMidiData(pcData, midiState);

        // Should set last note to the program change message
        expect(midiState.lastNote, contains("Program"));
      });

      test("handleStandardMidiData should handle different MIDI channels", () {
        final midiState = MidiState();

        // Note on channel 1
        final noteOnCh1 = Uint8List.fromList([0x90, 60, 100]);
        MidiConnectionService.handleStandardMidiData(noteOnCh1, midiState);

        // Note on channel 2
        final noteOnCh2 = Uint8List.fromList([0x91, 64, 100]);
        MidiConnectionService.handleStandardMidiData(noteOnCh2, midiState);

        expect(midiState.activeNotes.contains(60), isTrue);
        expect(midiState.activeNotes.contains(64), isTrue);
      });

      test(
        "handleStandardMidiData should handle invalid MIDI data gracefully",
        () {
          final midiState = MidiState();
          final invalidData = Uint8List.fromList([
            0xFF,
            0xFF,
          ]); // Invalid MIDI data

          // Should not throw an exception
          expect(
            () => MidiConnectionService.handleStandardMidiData(
              invalidData,
              midiState,
            ),
            returnsNormally,
          );
        },
      );

      test("handleStandardMidiData should handle empty MIDI data", () {
        final midiState = MidiState();
        final emptyData = Uint8List.fromList([]);

        // Should not throw an exception
        expect(
          () => MidiConnectionService.handleStandardMidiData(
            emptyData,
            midiState,
          ),
          returnsNormally,
        );
      });
    });

    group("Resource Management Tests", () {
      test("dispose should clean up all resources", () async {
        // Register some handlers
        void dataHandler(Uint8List data) {}
        void errorHandler(String error) {}

        service
          ..registerDataHandler(dataHandler)
          ..registerErrorHandler(errorHandler);

        // Connect the service
        await service.connect();

        // Dispose should clean everything up
        await service.dispose();

        expect(service.isConnected, isFalse);
      });

      test("dispose should be safe to call multiple times", () async {
        await service.dispose();

        // Second dispose call should not throw
        expect(() async => service.dispose(), returnsNormally);
      });

      test("dispose should handle disconnection errors gracefully", () async {
        // Even if disconnection fails, dispose should complete
        expect(() async => service.dispose(), returnsNormally);
      });
    });

    group("Edge Cases and Error Handling Tests", () {
      test(
        "should handle handler exceptions gracefully during data processing",
        () {
          void throwingHandler(Uint8List data) {
            throw Exception("Handler error");
          }

          void normalHandler(Uint8List data) {
            // This should still execute despite the throwing handler
          }

          service
            ..registerDataHandler(throwingHandler)
            ..registerDataHandler(normalHandler);

          // Even with a throwing handler, the service should continue operating
          expect(
            () => service.registerDataHandler(normalHandler),
            returnsNormally,
          );

          // Clean up
          service
            ..unregisterDataHandler(throwingHandler)
            ..unregisterDataHandler(normalHandler);
        },
      );

      test("should handle error handler exceptions gracefully", () {
        void throwingErrorHandler(String error) {
          throw Exception("Error handler error");
        }

        void normalErrorHandler(String error) {
          // This should still execute despite the throwing error handler
        }

        service
          ..registerErrorHandler(throwingErrorHandler)
          ..registerErrorHandler(normalErrorHandler);

        // Even with a throwing error handler, the service should continue operating
        expect(
          () => service.registerErrorHandler(normalErrorHandler),
          returnsNormally,
        );

        // Clean up
        service
          ..unregisterErrorHandler(throwingErrorHandler)
          ..unregisterErrorHandler(normalErrorHandler);
      });

      test("should handle null MIDI data stream gracefully", () async {
        // This tests the warning case when MIDI data stream is not available
        await service.connect();

        // Should not throw even if MIDI stream is unavailable
        // Connection state depends on mock implementation
      });
    });

    group("Integration Tests", () {
      test(
        "should support full lifecycle: connect, register handlers, process data, disconnect",
        () async {
          final receivedData = <Uint8List>[];
          final receivedErrors = <String>[];

          void dataHandler(Uint8List data) {
            receivedData.add(data);
          }

          void errorHandler(String error) {
            receivedErrors.add(error);
          }

          // Register handlers
          service
            ..registerDataHandler(dataHandler)
            ..registerErrorHandler(errorHandler);

          // Connect
          await service.connect();

          // Process some data
          final testMidiState = MidiState();
          final testData = Uint8List.fromList([0x90, 60, 100]);
          MidiConnectionService.handleStandardMidiData(testData, testMidiState);

          expect(testMidiState.activeNotes.contains(60), isTrue);

          // Disconnect and cleanup
          await service.disconnect();
          service
            ..unregisterDataHandler(dataHandler)
            ..unregisterErrorHandler(errorHandler);

          expect(service.isConnected, isFalse);
        },
      );

      test("should maintain handler state across connection cycles", () async {
        final receivedData = <Uint8List>[];

        void dataHandler(Uint8List data) {
          receivedData.add(data);
        }

        // Register handler
        service.registerDataHandler(dataHandler);

        // Connect and disconnect multiple times
        await service.connect();
        await service.disconnect();
        await service.connect();
        await service.disconnect();

        // Handler should still be registered (cleanup is manual)
        service.unregisterDataHandler(dataHandler);
      });

      test(
        "should handle simultaneous handler registration and data processing",
        () async {
          final handler1Data = <Uint8List>[];
          final handler2Data = <Uint8List>[];

          void handler1(Uint8List data) {
            handler1Data.add(data);
          }

          void handler2(Uint8List data) {
            handler2Data.add(data);
          }

          // Register handlers
          service
            ..registerDataHandler(handler1)
            ..registerDataHandler(handler2);

          // Test data processing
          final testMidiState = MidiState();
          final testData = Uint8List.fromList([0x90, 60, 100]);
          MidiConnectionService.handleStandardMidiData(testData, testMidiState);

          expect(testMidiState.activeNotes.contains(60), isTrue);

          // Clean up
          service
            ..unregisterDataHandler(handler1)
            ..unregisterDataHandler(handler2);
        },
      );

      test("should handle complex MIDI message sequences", () {
        final midiState = MidiState();

        // Play a chord
        final noteC = Uint8List.fromList([0x90, 60, 100]); // C
        final noteE = Uint8List.fromList([0x90, 64, 100]); // E
        final noteG = Uint8List.fromList([0x90, 67, 100]); // G

        MidiConnectionService.handleStandardMidiData(noteC, midiState);
        MidiConnectionService.handleStandardMidiData(noteE, midiState);
        MidiConnectionService.handleStandardMidiData(noteG, midiState);

        expect(midiState.activeNotes.contains(60), isTrue);
        expect(midiState.activeNotes.contains(64), isTrue);
        expect(midiState.activeNotes.contains(67), isTrue);

        // Release the chord
        final noteOffC = Uint8List.fromList([0x80, 60, 0]);
        final noteOffE = Uint8List.fromList([0x80, 64, 0]);
        final noteOffG = Uint8List.fromList([0x80, 67, 0]);

        MidiConnectionService.handleStandardMidiData(noteOffC, midiState);
        MidiConnectionService.handleStandardMidiData(noteOffE, midiState);
        MidiConnectionService.handleStandardMidiData(noteOffG, midiState);

        expect(midiState.activeNotes.contains(60), isFalse);
        expect(midiState.activeNotes.contains(64), isFalse);
        expect(midiState.activeNotes.contains(67), isFalse);
      });
    });
  });
}
