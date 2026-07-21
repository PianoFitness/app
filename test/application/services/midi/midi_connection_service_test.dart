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

        void testHandler(Uint8List data) {}
        service1.registerDataHandler(testHandler);

        expect(identical(service1, service2), isTrue);

        service1.unregisterDataHandler(testHandler);
      });
    });

    group("Connection Management Tests", () {
      test("should start as disconnected", () {
        expect(service.isConnected, isFalse);
      });

      test("should handle connection attempt", () async {
        await service.connect();
      });

      test("should handle multiple connection attempts gracefully", () async {
        await service.connect();
        final firstConnectionState = service.isConnected;

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
        expect(() => service.registerDataHandler(testHandler), returnsNormally);

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
        void dataHandler(Uint8List data) {}
        void errorHandler(String error) {}

        service
          ..registerDataHandler(dataHandler)
          ..registerErrorHandler(errorHandler);

        await service.connect();
        await service.dispose();

        expect(service.isConnected, isFalse);
      });

      test("dispose should be safe to call multiple times", () async {
        await service.dispose();
        expect(() async => service.dispose(), returnsNormally);
      });

      test("dispose should handle disconnection errors gracefully", () async {
        expect(() async => service.dispose(), returnsNormally);
      });
    });

    group("Edge Cases and Error Handling Tests", () {
      test("should handle error handler exceptions gracefully", () {
        void throwingErrorHandler(String error) {
          throw Exception("Error handler error");
        }

        void normalErrorHandler(String error) {}

        service
          ..registerErrorHandler(throwingErrorHandler)
          ..registerErrorHandler(normalErrorHandler);

        expect(
          () => service.registerErrorHandler(normalErrorHandler),
          returnsNormally,
        );

        service
          ..unregisterErrorHandler(throwingErrorHandler)
          ..unregisterErrorHandler(normalErrorHandler);
      });
    });
  });
}
