import "dart:typed_data";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";

class FakeMidiCommand implements midi_cmd.MidiCommand {
  Uint8List? lastSentData;

  @override
  void sendData(Uint8List data, {String? deviceId, int? timestamp}) {
    lastSentData = data;
  }


  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMidiConnectionService implements MidiConnectionService {
  bool _connected = false;
  bool throwOnConnect = false;
  final Set<void Function(Uint8List)> handlers = {};

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (throwOnConnect) {
      throw Exception("Connection error");
    }
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  void registerDataHandler(void Function(Uint8List p1) handler) {
    handlers.add(handler);
  }

  @override
  void unregisterDataHandler(void Function(Uint8List p1) handler) {
    handlers.remove(handler);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group("MidiRepositoryImpl Unit Tests", () {
    late FakeMidiConnectionService fakeService;
    late FakeMidiCommand fakeCommand;
    late MidiRepositoryImpl repo;

    setUp(() {
      fakeService = FakeMidiConnectionService();
      fakeCommand = FakeMidiCommand();
      repo = MidiRepositoryImpl(
        service: fakeService,
        midiCommand: fakeCommand,
        maxConnectionAttempts: 2,
        initialRetryDelayMs: 10,
        retryDelayMultiplier: 1,
      );
    });

    tearDown(() {
      repo.dispose();
    });

    test("initialize connects via service", () async {
      await repo.initialize();
      expect(fakeService.isConnected, isTrue);
    });

    test("initialize retries and throws on max attempts reached", () async {
      fakeService.throwOnConnect = true;
      expect(() => repo.initialize(), throwsA(isA<Exception>()));
    });

    test("registerDataHandler and unregisterDataHandler track handlers", () {
      void handler(Uint8List data) {}

      repo.registerDataHandler(handler);
      expect(fakeService.handlers, contains(handler));

      repo.unregisterDataHandler(handler);
      expect(fakeService.handlers, isNot(contains(handler)));
    });

    test("sendNoteOn and sendNoteOff validate input and execute", () async {
      await repo.sendNoteOn(60, 100, 0);
      expect(fakeCommand.lastSentData, isNotNull);

      await repo.sendNoteOff(60, 0);
      expect(fakeCommand.lastSentData, isNotNull);

      expect(() => repo.sendNoteOn(150, 100, 0), throwsArgumentError);

      expect(() => repo.sendNoteOff(60, 20), throwsRangeError);
    });

    test("sendControlChange, sendProgramChange, sendPitchBend validate inputs", () async {
      await repo.sendControlChange(1, 64, 0);
      expect(fakeCommand.lastSentData, isNotNull);

      await repo.sendProgramChange(5, 0);
      expect(fakeCommand.lastSentData, isNotNull);

      await repo.sendPitchBend(0.5, 0);
      expect(fakeCommand.lastSentData, isNotNull);

      expect(() => repo.sendControlChange(1, 64, 17), throwsRangeError);
    });

    test("connectedDevice returns null stub", () {
      expect(repo.connectedDevice, isNull);
    });

    test("dispose cleans up registered handlers", () {
      void handler(Uint8List data) {}
      repo.registerDataHandler(handler);
      expect(fakeService.handlers.length, equals(1));

      repo.dispose();
      expect(fakeService.handlers.length, equals(0));
    });
  });
}
