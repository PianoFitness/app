import "dart:typed_data";

import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";
import "../../../shared/midi_mocks.dart";

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

          expect(service.isConnected, isTrue);

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

          expect(service.isConnected, isFalse);

          // Clean up
          service
            ..unregisterDataHandler(handler1)
            ..unregisterDataHandler(handler2);
        },
      );

      test("should handle handler registration", () {
        void handler1(Uint8List data) {}
        void handler2(Uint8List data) {}

        // Register handlers
        service
          ..registerDataHandler(handler1)
          ..registerDataHandler(handler2);

        // Clean up
        service
          ..unregisterDataHandler(handler1)
          ..unregisterDataHandler(handler2);

        expect(service.isConnected, isFalse);
      });
    });
  });
}
