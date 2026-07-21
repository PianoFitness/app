import "dart:typed_data";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";

class FakeMidiCommand implements midi_cmd.MidiCommand {
  Uint8List? lastSentData;
  List<midi_cmd.MidiDevice>? mockDevices;
  midi_cmd.MidiDevice? connectedDevice;

  bool throwOnDevices = false;
  bool throwOnConnect = false;
  bool throwOnSendData = false;

  @override
  Future<List<midi_cmd.MidiDevice>?> get devices async {
    if (throwOnDevices) {
      throw Exception("Device error");
    }
    return mockDevices;
  }

  @override
  void sendData(Uint8List data, {String? deviceId, int? timestamp}) {
    if (throwOnSendData) {
      throw Exception("Send data error");
    }
    lastSentData = data;
  }

  @override
  Future<void> connectToDevice(
    midi_cmd.MidiDevice device, {
    List<midi_cmd.MidiPort>? ports,
    Duration? awaitConnectionTimeout,
  }) async {
    if (throwOnConnect) {
      throw Exception("Connect error");
    }
    connectedDevice = device;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMidiConnectionService implements MidiConnectionService {
  bool _connected = false;
  bool throwOnConnect = false;
  bool throwOnDisconnect = false;
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
    if (throwOnDisconnect) {
      throw Exception("Disconnect error");
    }
    _connected = false;
  }

  @override
  void registerDataHandler(void Function(Uint8List p1) handler) {
    handlers.add(handler);
  }

  @override
  void unregisterDataHandler(void Function(Uint8List p1) handler) {
    if (throwOnDisconnect) {
      throw Exception("Unregister error");
    }
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
    });

    test("sendControlChange, sendProgramChange, and sendPitchBend", () async {
      await repo.sendControlChange(7, 100, 0);
      expect(
        fakeCommand.lastSentData,
        equals(Uint8List.fromList([0xB0, 7, 100])),
      );

      await repo.sendProgramChange(5, 0);
      expect(fakeCommand.lastSentData, equals(Uint8List.fromList([0xC0, 5])));

      await repo.sendPitchBend(0.0, 0);
      expect(fakeCommand.lastSentData, isNotNull);
    });

    test(
      "listDevices handles errors gracefully and returns empty list",
      () async {
        fakeCommand.throwOnDevices = true;
        final devices = await repo.listDevices();
        expect(devices, isEmpty);
      },
    );

    test("listDevices returns mapped devices", () async {
      final device = midi_cmd.MidiDevice(
        "dev1",
        "Piano",
        midi_cmd.MidiDeviceType.values.first,
        true,
      );
      fakeCommand.mockDevices = [device];

      final devices = await repo.listDevices();
      expect(devices.length, equals(1));
      expect(devices.first.id, equals("dev1"));
      expect(devices.first.name, equals("Piano"));
    });

    test("connectToDevice handles error rethrow", () async {
      final device = midi_cmd.MidiDevice(
        "dev1",
        "Piano",
        midi_cmd.MidiDeviceType.values.first,
        false,
      );
      fakeCommand.mockDevices = [device];
      fakeCommand.throwOnConnect = true;

      expect(() => repo.connectToDevice("dev1"), throwsA(isA<Exception>()));
    });

    test("connectToDevice connects to matching device", () async {
      final device = midi_cmd.MidiDevice(
        "dev1",
        "Piano",
        midi_cmd.MidiDeviceType.values.first,
        false,
      );
      fakeCommand.mockDevices = [device];

      await repo.connectToDevice("dev1");
      expect(fakeCommand.connectedDevice, equals(device));
    });

    test("disconnect rethrows error on failure", () async {
      fakeService.throwOnDisconnect = true;
      expect(() => repo.disconnect(), throwsA(isA<Exception>()));
    });

    test("sendData rethrows error on failure", () async {
      fakeCommand.throwOnSendData = true;
      expect(
        () => repo.sendData(Uint8List.fromList([0x90, 60, 64])),
        throwsA(isA<Exception>()),
      );
    });

    test("disconnect and connectedDevice getter", () async {
      await repo.disconnect();
      expect(fakeService.isConnected, isFalse);
      expect(repo.connectedDevice, isNull);
      expect(repo.midiDataStream, isNotNull);
    });
  });
}
